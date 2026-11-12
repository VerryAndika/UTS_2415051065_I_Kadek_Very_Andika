import '../models/saved_book.dart';

// Kontrak sumber data koleksi (CRUD). Implementasi: memori / database.
abstract class SavedBookDataSource {
  Future<List<SavedBook>> getAll();
  Future<SavedBook> create(SavedBook book);
  Future<SavedBook> update(SavedBook book);
  Future<void> delete(int id);
}

// Implementasi sementara di memori (sebelum database terhubung).
class InMemorySavedBookService implements SavedBookDataSource {
  final _rows = <SavedBook>[];
  int _nextId = 1;

  @override
  Future<List<SavedBook>> getAll() async => List.unmodifiable(_rows);

  @override
  Future<SavedBook> create(SavedBook book) async {
    final row = SavedBook.fromJson({
      ...book.toJson(),
      'id': _nextId++,
      'created_at': DateTime.now().toIso8601String(),
    });
    _rows.insert(0, row);
    return row;
  }

  @override
  Future<SavedBook> update(SavedBook book) async {
    final i = _rows.indexWhere((r) => r.id == book.id);
    if (i < 0) throw StateError('Data tidak ditemukan');
    _rows[i] = book;
    return book;
  }

  @override
  Future<void> delete(int id) async => _rows.removeWhere((r) => r.id == id);
}
