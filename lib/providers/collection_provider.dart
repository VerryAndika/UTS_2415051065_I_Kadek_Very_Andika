import 'package:flutter/foundation.dart';

import '../models/reading_status.dart';
import '../models/saved_book.dart';
import '../services/app_exception.dart';
import '../repositories/saved_book_repository.dart';

// Urutan daftar koleksi.
enum CollectionSort {
  newest('Terbaru'),
  title('Judul A–Z'),
  rating('Rating tertinggi'),
  progress('Progress terbanyak');

  const CollectionSort(this.label);
  final String label;
}

// Shared state koleksi bacaan: dipakai Home (statistik), Katalog/Detail
// (status tersimpan), dan Koleksi (daftar, filter, urutan).
// State minimum: loading / data / error.
class CollectionProvider extends ChangeNotifier {
  CollectionProvider(this._repository);

  final SavedBookRepository _repository;

  List<SavedBook> _items = [];
  bool _isLoading = false;
  AppException? _error;
  ReadingStatus? _filter; // null = semua status
  CollectionSort _sort = CollectionSort.newest;

  List<SavedBook> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error?.message;
  bool get errorIsNetwork => _error?.isNetwork ?? false;
  ReadingStatus? get filter => _filter;
  CollectionSort get sort => _sort;

  /// Daftar setelah filter status + urutan diterapkan.
  List<SavedBook> get visibleItems {
    final list = _filter == null
        ? [..._items]
        : _items.where((b) => b.status == _filter).toList();
    switch (_sort) {
      case CollectionSort.newest:
        list.sort(
          (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
            a.createdAt ?? DateTime(0),
          ),
        );
      case CollectionSort.title:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
      case CollectionSort.rating:
        list.sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
      case CollectionSort.progress:
        list.sort((a, b) => (b.progress ?? 0).compareTo(a.progress ?? 0));
    }
    return list;
  }

  void setFilter(ReadingStatus? status) {
    _filter = status;
    notifyListeners();
  }

  void setSort(CollectionSort sort) {
    _sort = sort;
    notifyListeners();
  }

  // --- Statistik bacaan (fitur tambahan) ---
  int countByStatus(ReadingStatus status) =>
      _items.where((b) => b.status == status).length;

  double? get averageRating {
    final rated = _items.where((b) => b.rating != null).toList();
    if (rated.isEmpty) return null;
    return rated.fold<int>(0, (sum, b) => sum + b.rating!) / rated.length;
  }

  int get pagesRead => _items.fold(0, (sum, b) => sum + b.currentPage);

  List<SavedBook> get currentlyReading =>
      _items.where((b) => b.status == ReadingStatus.reading).toList();

  bool isSaved(String bookKey) => _items.any((b) => b.bookKey == bookKey);

  SavedBook? findByKey(String bookKey) {
    for (final b in _items) {
      if (b.bookKey == bookKey) return b;
    }
    return null;
  }

  SavedBook? findById(int? id) {
    for (final b in _items) {
      if (b.id == id) return b;
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
      _error = AppException.from(e, action: 'memuat koleksi');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<SavedBook> add(SavedBook book) async {
    final created = await _repository.create(book);
    _items = [created, ..._items];
    notifyListeners();
    return created;
  }

  Future<SavedBook> update(SavedBook book) async {
    final updated = await _repository.update(book);
    _items = [for (final b in _items) b.id == updated.id ? updated : b];
    notifyListeners();
    return updated;
  }

  /// Update cepat progress halaman (+/-) dari halaman detail koleksi.
  Future<SavedBook> changePage(SavedBook book, int delta) {
    var page = (book.currentPage + delta).clamp(0, book.totalPages ?? 1 << 30);
    var status = book.status;
    if (page > 0 && status == ReadingStatus.want) {
      status = ReadingStatus.reading;
    }
    if (book.totalPages != null && page >= book.totalPages!) {
      page = book.totalPages!;
    }
    return update(book.copyWith(currentPage: page, status: status));
  }

  Future<void> remove(SavedBook book) async {
    final id = book.id;
    if (id == null) return;
    await _repository.delete(id);
    _items = _items.where((b) => b.id != id).toList();
    notifyListeners();
  }
}
