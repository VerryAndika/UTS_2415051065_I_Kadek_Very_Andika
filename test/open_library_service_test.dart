import 'dart:convert';

import 'package:bookfinder/models/book.dart';
import 'package:bookfinder/services/open_library_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('searchBooks mem-parsing docs menjadi List<Book>', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/search.json');
      expect(request.url.queryParameters['q'], 'clean code');
      return http.Response(
        jsonEncode({
          'docs': [
            {
              'key': '/works/OL17618370W',
              'title': 'Clean Code',
              'author_name': ['Robert C. Martin'],
            },
          ],
        }),
        200,
      );
    });

    final books = await OpenLibraryService(client: client)
        .searchBooks('clean code');
    expect(books, hasLength(1));
    expect(books.first.title, 'Clean Code');
  });

  test('status selain 200 -> exception', () async {
    final client = MockClient((_) async => http.Response('oops', 500));
    expect(
      OpenLibraryService(client: client).searchBooks('x'),
      throwsException,
    );
  });

  test('getBookDetail membaca description berbentuk objek', () async {
    final client = MockClient(
      (_) async => http.Response(
        jsonEncode({
          'description': {'type': '/type/text', 'value': 'Isi buku'},
          'subjects': ['Programming'],
        }),
        200,
      ),
    );
    final detail = await OpenLibraryService(client: client)
        .getBookDetail(const Book(key: '/works/OL1W', title: 'X'));
    expect(detail.description, 'Isi buku');
    expect(detail.subjects, ['Programming']);
  });
}
