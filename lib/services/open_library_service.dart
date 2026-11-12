import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../models/book.dart';
import 'book_data_source.dart';

// REST API Open Library (https://openlibrary.org/developers/api), tanpa API key.
//   GET /search.json?q={query}&limit=24&fields=...   -> daftar buku
//   GET /works/{id}.json                             -> deskripsi & subjek
class OpenLibraryService implements BookDataSource {
  OpenLibraryService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _fields =
      'key,title,author_name,first_publish_year,cover_i,'
      'number_of_pages_median,subject';

  @override
  Future<List<Book>> searchBooks(String query) async {
    final uri = Uri.parse(
      '${AppConfig.openLibraryBaseUrl}/search.json',
    ).replace(queryParameters: {'q': query, 'limit': '24', 'fields': _fields});
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat buku (HTTP ${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final docs = body['docs'] as List<dynamic>? ?? const [];
    return docs.whereType<Map<String, dynamic>>().map(Book.fromJson).toList();
  }

  @override
  Future<Book> getBookDetail(Book book) async {
    final uri = Uri.parse('${AppConfig.openLibraryBaseUrl}${book.key}.json');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Gagal memuat detail buku (HTTP ${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
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
