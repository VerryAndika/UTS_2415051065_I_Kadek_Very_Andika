import '../models/book.dart';
import '../services/book_data_source.dart';

// Repository katalog: satu-satunya pintu provider untuk data buku.
// Sumber data (contoh lokal / REST API) bisa diganti tanpa mengubah UI.
class BookRepository {
  BookRepository(this._source);

  final BookDataSource _source;

  Future<List<Book>> searchBooks(String query) {
    final q = query.trim();
    if (q.isEmpty) return Future.value(const []);
    return _source.searchBooks(q);
  }

  Future<Book> getBookDetail(Book book) => _source.getBookDetail(book);
}
