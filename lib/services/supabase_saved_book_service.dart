import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../models/saved_book.dart';
import 'saved_book_data_source.dart';

// CRUD tabel `saved_books` di Supabase (PostgreSQL) lewat supabase_flutter.
class SupabaseSavedBookService implements SavedBookDataSource {
  SupabaseSavedBookService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  SupabaseQueryBuilder get _table =>
      _client.from(SupabaseConfig.savedBooksTable);

  // READ: koleksi milik mahasiswa ini, terbaru di atas.
  @override
  Future<List<SavedBook>> getAll() async {
    final rows = await _table
        .select()
        .eq('student_id', AppConfig.studentId)
        .order('created_at', ascending: false);
    return rows.map(SavedBook.fromJson).toList();
  }

  // CREATE: INSERT lalu kembalikan baris baru (id & created_at dari database).
  @override
  Future<SavedBook> create(SavedBook book) async {
    final row = await _table.insert(book.toJson()).select().single();
    return SavedBook.fromJson(row);
  }

  // UPDATE berdasarkan id. select() memastikan baris benar-benar berubah
  // (jika id tidak ada / ditolak RLS, Supabase tidak menganggapnya error).
  @override
  Future<SavedBook> update(SavedBook book) async {
    final id = book.id;
    if (id == null) throw ArgumentError('Data belum memiliki id');
    final rows = await _table
        .update({
          ...book.toJson(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', id)
        .select();
    if (rows.isEmpty) {
      throw StateError('Data tidak ditemukan atau tidak boleh diubah');
    }
    return SavedBook.fromJson(rows.first);
  }

  @override
  Future<void> delete(int id) {
    throw UnimplementedError('Delete diimplementasikan pada tahap berikutnya');
  }
}
