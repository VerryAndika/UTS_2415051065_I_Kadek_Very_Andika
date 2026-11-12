import 'package:flutter/foundation.dart';

import '../models/reading_status.dart';
import '../models/saved_book.dart';
import '../repositories/saved_book_repository.dart';

// Shared state koleksi bacaan: dipakai Home (statistik), Katalog/Detail
// (status tersimpan), dan Koleksi (daftar). Loading / data / error.
class CollectionProvider extends ChangeNotifier {
  CollectionProvider(this._repository);

  final SavedBookRepository _repository;

  List<SavedBook> _items = [];
  bool _isLoading = false;
  String? _error;

  List<SavedBook> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isSaved(String bookKey) => _items.any((b) => b.bookKey == bookKey);

  SavedBook? findByKey(String bookKey) {
    for (final b in _items) {
      if (b.bookKey == bookKey) return b;
    }
    return null;
  }

  int countByStatus(ReadingStatus status) =>
      _items.where((b) => b.status == status).length;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _repository.getAll();
    } catch (e) {
      _error = e.toString();
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

  SavedBook? findById(int? id) {
    for (final b in _items) {
      if (b.id == id) return b;
    }
    return null;
  }

  Future<void> remove(SavedBook book) async {
    final id = book.id;
    if (id == null) return;
    await _repository.delete(id);
    _items = _items.where((b) => b.id != id).toList();
    notifyListeners();
  }
}
