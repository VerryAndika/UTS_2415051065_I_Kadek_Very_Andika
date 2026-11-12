import '../config/app_config.dart';
import 'book.dart';
import 'reading_status.dart';

// Model satu baris tabel `saved_books` (Supabase/PostgreSQL).
class SavedBook {
  const SavedBook({
    this.id,
    required this.bookKey,
    required this.title,
    required this.author,
    this.coverUrl,
    this.status = ReadingStatus.want,
    this.rating,
    this.note,
    this.currentPage = 0,
    this.totalPages,
    this.createdAt,
    this.updatedAt,
  });

  final int? id; // primary key (null sebelum disimpan)
  final String bookKey;
  final String title;
  final String author;
  final String? coverUrl;
  final ReadingStatus status;
  final int? rating; // 1–5
  final String? note;
  final int currentPage;
  final int? totalPages;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Data awal ketika buku dari katalog API ditambahkan ke koleksi.
  factory SavedBook.fromBook(Book book) => SavedBook(
    bookKey: book.key,
    title: book.title,
    author: book.authorText,
    coverUrl: book.coverUrl(),
    totalPages: book.pageCount,
  );

  factory SavedBook.fromJson(Map<String, dynamic> json) => SavedBook(
    id: (json['id'] as num?)?.toInt(),
    bookKey: json['book_key'] as String? ?? '',
    title: json['title'] as String? ?? 'Tanpa judul',
    author: json['author'] as String? ?? 'Unknown',
    coverUrl: json['cover_url'] as String?,
    status: ReadingStatus.fromValue(json['status'] as String?),
    rating: (json['rating'] as num?)?.toInt(),
    note: json['note'] as String?,
    currentPage: (json['current_page'] as num?)?.toInt() ?? 0,
    totalPages: (json['total_pages'] as num?)?.toInt(),
    createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
  );

  /// Payload insert/update. `id` & `created_at` diisi oleh database.
  Map<String, dynamic> toJson() => {
    'student_id': AppConfig.studentId,
    'book_key': bookKey,
    'title': title,
    'author': author,
    'cover_url': coverUrl,
    'status': status.value,
    'rating': rating,
    'note': note,
    'current_page': currentPage,
    'total_pages': totalPages,
  };

  /// Progress baca 0.0–1.0 (null jika jumlah halaman tidak diketahui).
  double? get progress {
    final total = totalPages;
    if (total == null || total <= 0) return null;
    if (status == ReadingStatus.done) return 1;
    return (currentPage / total).clamp(0, 1).toDouble();
  }

  SavedBook copyWith({
    ReadingStatus? status,
    int? rating,
    bool clearRating = false,
    String? note,
    int? currentPage,
    int? totalPages,
  }) => SavedBook(
    id: id,
    bookKey: bookKey,
    title: title,
    author: author,
    coverUrl: coverUrl,
    status: status ?? this.status,
    rating: clearRating ? null : (rating ?? this.rating),
    note: note ?? this.note,
    currentPage: currentPage ?? this.currentPage,
    totalPages: totalPages ?? this.totalPages,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
