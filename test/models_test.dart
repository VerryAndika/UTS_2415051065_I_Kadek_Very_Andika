import 'package:bookfinder/models/book.dart';
import 'package:bookfinder/models/reading_status.dart';
import 'package:bookfinder/models/saved_book.dart';
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

  group('SavedBook', () {
    test('fromJson / toJson konsisten dengan kolom tabel', () {
      final saved = SavedBook.fromJson({
        'id': 7,
        'book_key': '/works/OL1W',
        'title': 'Buku',
        'author': 'Penulis',
        'status': 'reading',
        'rating': 4,
        'current_page': 50,
        'total_pages': 200,
        'created_at': '2026-11-12T10:00:00Z',
      });

      expect(saved.id, 7);
      expect(saved.status, ReadingStatus.reading);
      expect(saved.progress, 0.25);
      final json = saved.toJson();
      expect(json['status'], 'reading');
      expect(json.containsKey('id'), isFalse);
    });

    test('status tidak dikenal -> default want', () {
      expect(ReadingStatus.fromValue('x'), ReadingStatus.want);
    });
  });
}
