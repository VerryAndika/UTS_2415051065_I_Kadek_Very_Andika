import 'package:bookfinder/models/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Book.fromJson', () {
    test('mengubah item search Open Library menjadi Book', () {
      final book = Book.fromJson({
        'key': '/works/OL17618370W',
        'title': 'Clean Code',
        'author_name': ['Robert C. Martin'],
        'first_publish_year': 2008,
        'cover_i': 8065615,
        'number_of_pages_median': 444,
      });

      expect(book.title, 'Clean Code');
      expect(book.authorText, 'Robert C. Martin');
      expect(book.coverUrl(), contains('8065615-M.jpg'));
      expect(book.pageCount, 444);
    });

    test('field opsional yang hilang tidak membuat crash', () {
      final book = Book.fromJson({'key': '/works/OL1W'});
      expect(book.title, 'Tanpa judul');
      expect(book.authorText, 'Penulis tidak diketahui');
      expect(book.coverUrl(), isNull);
    });

    test('tanpa key -> FormatException', () {
      expect(() => Book.fromJson({'title': 'X'}), throwsFormatException);
    });
  });
}
