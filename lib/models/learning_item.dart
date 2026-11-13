import '../config/app_config.dart';
import 'book.dart';
import 'item_status.dart';
import 'media_type.dart';

// Satu Learning Item = satu baris tabel `learning_items`.
// Bukan sekadar judul + link: menyimpan sumber rekomendasi, karakteristik,
// alasan disimpan, status eksplorasi, dan catatan pemahaman.
class LearningItem {
  const LearningItem({
    this.id,
    required this.title,
    this.mediaType = MediaType.book,
    this.topic = 'Umum',
    this.creator,
    this.url,
    this.source = 'Manual',
    this.description,
    this.characteristics = const [],
    this.reason,
    this.status = ItemStatus.inbox,
    this.notes,
    this.rating,
    this.coverUrl,
    this.externalKey,
    this.createdAt,
    this.updatedAt,
  });

  final int? id; // primary key (null sebelum disimpan)
  final String title;
  final MediaType mediaType;
  final String topic;
  final String? creator;
  final String? url;
  final String source;
  final String? description;
  final List<String> characteristics;
  final String? reason;
  final ItemStatus status;
  final String? notes;
  final int? rating;
  final String? coverUrl;
  final String? externalKey;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Sumber rekomendasi yang umum (pilihan cepat di form).
  static const commonSources = [
    'TikTok',
    'YouTube',
    'Instagram',
    'Google',
    'Website',
    'Teman',
    'Dosen',
    'Open Library',
    'Manual',
  ];

  /// Item awal dari hasil Discover (Open Library).
  factory LearningItem.fromBook(Book book) => LearningItem(
    title: book.title,
    mediaType: MediaType.book,
    topic: book.subjects.isNotEmpty ? _cleanTopic(book.subjects.first) : 'Umum',
    creator: book.authorText,
    url: 'https://openlibrary.org${book.key}',
    source: 'Open Library',
    description: book.description,
    characteristics: [
      if (book.firstPublishYear != null) 'Terbit ${book.firstPublishYear}',
      if (book.pageCount != null) '${book.pageCount} halaman',
      ...book.subjects.skip(1).take(3).map(_cleanTopic),
    ],
    coverUrl: book.coverUrl(),
    externalKey: book.key,
  );

  static String _cleanTopic(String s) {
    final t = s.split(RegExp(r'[,(]')).first.trim();
    return t.isEmpty ? 'Umum' : t[0].toUpperCase() + t.substring(1);
  }

  static List<String> parseTags(String? text) => (text ?? '')
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();

  factory LearningItem.fromJson(Map<String, dynamic> json) => LearningItem(
    id: (json['id'] as num?)?.toInt(),
    title: json['title'] as String? ?? 'Tanpa judul',
    mediaType: MediaType.fromValue(json['media_type'] as String?),
    topic: (json['topic'] as String?)?.trim().isNotEmpty == true
        ? (json['topic'] as String).trim()
        : 'Umum',
    creator: json['creator'] as String?,
    url: json['url'] as String?,
    source: json['source'] as String? ?? 'Manual',
    description: json['description'] as String?,
    characteristics: parseTags(json['characteristics'] as String?),
    reason: json['reason'] as String?,
    status: ItemStatus.fromValue(json['status'] as String?),
    notes: json['notes'] as String?,
    rating: (json['rating'] as num?)?.toInt(),
    coverUrl: json['cover_url'] as String?,
    externalKey: json['external_key'] as String?,
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
  );

  /// Payload insert/update; `id` & `created_at` diisi database.
  Map<String, dynamic> toJson() => {
    'student_id': AppConfig.studentId,
    'title': title.trim(),
    'media_type': mediaType.value,
    'topic': topic.trim().isEmpty ? 'Umum' : topic.trim(),
    'creator': _nullIfEmpty(creator),
    'url': _nullIfEmpty(url),
    'source': source.trim().isEmpty ? 'Manual' : source.trim(),
    'description': _nullIfEmpty(description),
    'characteristics': characteristics.isEmpty
        ? null
        : characteristics.join(', '),
    'reason': _nullIfEmpty(reason),
    'status': status.value,
    'notes': _nullIfEmpty(notes),
    'rating': rating,
    'cover_url': _nullIfEmpty(coverUrl),
    'external_key': _nullIfEmpty(externalKey),
  };

  static String? _nullIfEmpty(String? s) =>
      s == null || s.trim().isEmpty ? null : s.trim();

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return [
      title,
      topic,
      creator ?? '',
      source,
      description ?? '',
      reason ?? '',
      ...characteristics,
    ].any((s) => s.toLowerCase().contains(q));
  }

  LearningItem copyWith({ItemStatus? status, String? notes, int? rating}) =>
      LearningItem(
        id: id,
        title: title,
        mediaType: mediaType,
        topic: topic,
        creator: creator,
        url: url,
        source: source,
        description: description,
        characteristics: characteristics,
        reason: reason,
        status: status ?? this.status,
        notes: notes ?? this.notes,
        rating: rating ?? this.rating,
        coverUrl: coverUrl,
        externalKey: externalKey,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
