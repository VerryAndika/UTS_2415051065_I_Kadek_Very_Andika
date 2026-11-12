import '../models/saved_book.dart';
import '../services/saved_book_data_source.dart';

// Repository koleksi bacaan (CRUD) di atas SavedBookDataSource.
class SavedBookRepository {
  SavedBookRepository(this._source);

  final SavedBookDataSource _source;

  Future<List<SavedBook>> getAll() => _source.getAll();
  Future<SavedBook> create(SavedBook book) => _source.create(book);
  Future<SavedBook> update(SavedBook book) => _source.update(book);
  Future<void> delete(int id) => _source.delete(id);
}
