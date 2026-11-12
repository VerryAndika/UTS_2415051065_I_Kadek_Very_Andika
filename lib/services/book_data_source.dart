import '../models/book.dart';
import '../models/sample_books.dart';

// Kontrak sumber data katalog buku. Implementasi: data contoh / REST API.
abstract class BookDataSource {
  Future<List<Book>> searchBooks(String query);
  Future<Book> getBookDetail(Book book);
}

// Sumber data sementara: data contoh lokal dengan jeda seolah-olah network.
class SampleBookService implements BookDataSource {
  @override
  Future<List<Book>> searchBooks(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final q = query.toLowerCase();
    return sampleBooks
        .where(
          (b) =>
              b.title.toLowerCase().contains(q) ||
              b.authorText.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Future<Book> getBookDetail(Book book) async => book;
}
