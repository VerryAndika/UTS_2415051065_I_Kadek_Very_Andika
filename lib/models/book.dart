import '../config/app_config.dart';

// Model buku dari REST API Open Library (endpoint /search.json & /works/{id}.json).
class Book {
  const Book({
    required this.key,
    required this.title,
    this.authors = const [],
    this.firstPublishYear,
    this.coverId,
    this.pageCount,
    this.subjects = const [],
    this.description,
  });

  /// Key work Open Library, mis. `/works/OL17618370W`.
  final String key;
  final String title;
  final List<String> authors;
  final int? firstPublishYear;
  final int? coverId;
  final int? pageCount;
  final List<String> subjects;
  final String? description;

  /// Mengubah satu item `docs` dari `/search.json` menjadi [Book].
  /// Field yang hilang/null ditangani agar tidak crash (null safety).
  factory Book.fromJson(Map<String, dynamic> json) {
    final key = json['key'];
    if (key is! String || key.isEmpty) {
      throw const FormatException('Data buku tidak memiliki "key"');
    }
    return Book(
      key: key,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Tanpa judul',
      authors: _stringList(json['author_name']),
      firstPublishYear: (json['first_publish_year'] as num?)?.toInt(),
      coverId: (json['cover_i'] as num?)?.toInt(),
      pageCount: (json['number_of_pages_median'] as num?)?.toInt(),
      subjects: _stringList(json['subject']).take(8).toList(),
    );
  }

  static List<String> _stringList(Object? value) =>
      value is List ? value.whereType<String>().toList() : const [];

  String get authorText =>
      authors.isEmpty ? 'Penulis tidak diketahui' : authors.take(2).join(', ');

  /// URL cover dari Covers API (S, M, L).
  String? coverUrl([String size = 'M']) => coverId == null
      ? null
      : '${AppConfig.coverBaseUrl}/b/id/$coverId-$size.jpg';

  Book copyWith({String? description, List<String>? subjects}) => Book(
    key: key,
    title: title,
    authors: authors,
    firstPublishYear: firstPublishYear,
    coverId: coverId,
    pageCount: pageCount,
    subjects: subjects ?? this.subjects,
    description: description ?? this.description,
  );
}
