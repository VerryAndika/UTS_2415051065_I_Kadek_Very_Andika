import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/book.dart';
import 'app_exception.dart';
import 'book_data_source.dart';

// REST API Open Library (https://openlibrary.org/developers/api), tanpa API key.
//   GET /search.json?q={query}&limit=24&fields=...   -> daftar buku
//   GET /works/{id}.json                             -> deskripsi & subjek
class OpenLibraryService implements BookDataSource {
  OpenLibraryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const timeout = Duration(seconds: 15);
  static const _fields =
      'key,title,author_name,first_publish_year,cover_i,'
      'number_of_pages_median,subject';

  /// GET + timeout + cek status + decode JSON. Semua error teknis
  /// diterjemahkan menjadi AppException.
  Future<Map<String, dynamic>> _getJson(Uri uri, String action) async {
    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode != 200) {
        throw AppException.httpStatus(response.statusCode, action: action);
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Root JSON bukan object');
      }
      return decoded;
    } on TypeError {
      throw AppException.from(const FormatException(), action: action);
    } catch (e) {
      throw AppException.from(e, action: action);
    }
  }

  @override
  Future<List<Book>> searchBooks(String query) async {
    final uri = Uri.parse(
      '${AppConfig.openLibraryBaseUrl}/search.json',
    ).replace(queryParameters: {'q': query, 'limit': '24', 'fields': _fields});
    final body = await _getJson(uri, 'memuat daftar buku');

    final docs = body['docs'];
    if (docs is! List) {
      throw AppException.from(
        const FormatException(),
        action: 'memuat daftar buku',
      );
    }
    final books = <Book>[];
    for (final item in docs.whereType<Map<String, dynamic>>()) {
      try {
        books.add(Book.fromJson(item));
      } on FormatException {
        // Lewati item yang tidak lengkap, tanpa menggagalkan seluruh daftar.
      }
    }
    return books;
  }

  @override
  Future<Book> getBookDetail(Book book) async {
    final uri = Uri.parse('${AppConfig.openLibraryBaseUrl}${book.key}.json');
    final json = await _getJson(uri, 'memuat detail buku');

    // `description` bisa berupa String atau {"type": ..., "value": "..."}.
    final raw = json['description'];
    final description = raw is String
        ? raw
        : raw is Map
        ? raw['value'] as String?
        : null;
    final subjects = (json['subjects'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .take(8)
        .toList();

    return book.copyWith(
      description: description?.trim(),
      subjects: subjects.isEmpty ? null : subjects,
    );
  }
}
