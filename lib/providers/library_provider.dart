import 'package:flutter/foundation.dart';

import '../models/item_status.dart';
import '../models/learning_item.dart';
import '../models/media_type.dart';
import '../repositories/learning_item_repository.dart';
import '../services/app_exception.dart';

enum LibrarySort {
  newest('Terbaru'),
  title('Judul A–Z'),
  topic('Topik'),
  rating('Rating tertinggi');

  const LibrarySort(this.label);
  final String label;
}

// Shared state Learning Library: dipakai Home, Library, Queue, Discover,
// Item Profile, dan Insights. State minimum: loading / data / error.
class LibraryProvider extends ChangeNotifier {
  LibraryProvider(this._repository);

  final LearningItemRepository _repository;

  List<LearningItem> _items = [];
  bool _isLoading = false;
  AppException? _error;

  // Filter & urutan Library.
  String _query = '';
  MediaType? _mediaFilter;
  String? _topicFilter;
  ItemStatus? _statusFilter;
  LibrarySort _sort = LibrarySort.newest;

  List<LearningItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error?.message;
  bool get errorIsNetwork => _error?.isNetwork ?? false;
  String get query => _query;
  MediaType? get mediaFilter => _mediaFilter;
  String? get topicFilter => _topicFilter;
  ItemStatus? get statusFilter => _statusFilter;
  LibrarySort get sort => _sort;
  bool get hasFilter =>
      _query.isNotEmpty ||
      _mediaFilter != null ||
      _topicFilter != null ||
      _statusFilter != null;

  /// Item setelah pencarian, filter (media, topik, status), dan urutan.
  List<LearningItem> get visibleItems {
    final list = _items
        .where(
          (i) =>
              i.matches(_query) &&
              (_mediaFilter == null || i.mediaType == _mediaFilter) &&
              (_topicFilter == null || i.topic == _topicFilter) &&
              (_statusFilter == null || i.status == _statusFilter),
        )
        .toList();
    switch (_sort) {
      case LibrarySort.newest:
        list.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
      case LibrarySort.title:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case LibrarySort.topic:
        list.sort((a, b) => a.topic.compareTo(b.topic));
      case LibrarySort.rating:
        list.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    }
    return list;
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setMediaFilter(MediaType? m) {
    _mediaFilter = m;
    notifyListeners();
  }

  void setTopicFilter(String? t) {
    _topicFilter = t;
    notifyListeners();
  }

  void setStatusFilter(ItemStatus? s) {
    _statusFilter = s;
    notifyListeners();
  }

  void setSort(LibrarySort s) {
    _sort = s;
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _mediaFilter = null;
    _topicFilter = null;
    _statusFilter = null;
    notifyListeners();
  }

  // --- Ringkasan (Home & Insights) ---
  int countByMedia(MediaType m) => _items.where((i) => i.mediaType == m).length;
  int countByStatus(ItemStatus s) => _items.where((i) => i.status == s).length;

  List<LearningItem> byStatus(ItemStatus s) =>
      _items.where((i) => i.status == s).toList();

  List<LearningItem> get recent {
    final list = [..._items]
      ..sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    return list.take(6).toList();
  }

  /// Topik beserta jumlah item, terbanyak di atas.
  List<MapEntry<String, int>> get topicCounts => _countBy((i) => i.topic);

  /// Sumber rekomendasi beserta jumlah item, terbanyak di atas.
  List<MapEntry<String, int>> get sourceCounts => _countBy((i) => i.source);

  List<String> get topics => topicCounts.map((e) => e.key).toList();

  List<MapEntry<String, int>> _countBy(String Function(LearningItem) key) {
    final map = <String, int>{};
    for (final i in _items) {
      map.update(key(i), (v) => v + 1, ifAbsent: () => 1);
    }
    return map.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
  }

  double get completionRate =>
      _items.isEmpty ? 0 : countByStatus(ItemStatus.done) / _items.length;

  int get itemsWithNotes =>
      _items.where((i) => (i.notes ?? '').trim().isNotEmpty).length;

  LearningItem? findById(int? id) {
    for (final i in _items) {
      if (i.id == id) return i;
    }
    return null;
  }

  LearningItem? findByExternalKey(String key) {
    for (final i in _items) {
      if (i.externalKey == key) return i;
    }
    return null;
  }

  // --- CRUD ---
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repository.getAll();
    } catch (e) {
      _error = AppException.from(e, action: 'memuat library');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LearningItem> add(LearningItem item) async {
    final created = await _repository.create(item);
    _items = [created, ..._items];
    notifyListeners();
    return created;
  }

  Future<LearningItem> update(LearningItem item) async {
    final updated = await _repository.update(item);
    _items = [for (final i in _items) i.id == updated.id ? updated : i];
    notifyListeners();
    return updated;
  }

  Future<LearningItem> setStatus(LearningItem item, ItemStatus status) =>
      update(item.copyWith(status: status));

  Future<void> remove(LearningItem item) async {
    final id = item.id;
    if (id == null) return;
    await _repository.delete(id);
    _items = _items.where((i) => i.id != id).toList();
    notifyListeners();
  }
}
