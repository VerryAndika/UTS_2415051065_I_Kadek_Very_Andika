import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../models/saved_book.dart';
import 'app_exception.dart';
import 'saved_book_data_source.dart';

// CRUD tabel `saved_books` di Supabase (PostgreSQL) lewat supabase_flutter.
// Error database (constraint, RLS, jaringan) diterjemahkan ke AppException.
class SupabaseSavedBookService implements SavedBookDataSource {
  SupabaseSavedBookService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const timeout = Duration(seconds: 15);

  SupabaseQueryBuilder get _table =>
      _client.from(SupabaseConfig.savedBooksTable);

  Future<T> _run<T>(String action, Future<T> Function() query) async {
    try {
      return await query().timeout(timeout);
    } catch (e) {
      throw AppException.from(e, action: action);
    }
  }

  // READ: koleksi milik mahasiswa ini, terbaru di atas.
  @override
  Future<List<SavedBook>> getAll() => _run('memuat koleksi', () async {
    final rows = await _table
        .select()
        .eq('student_id', AppConfig.studentId)
        .order('created_at', ascending: false);
    return rows.map(SavedBook.fromJson).toList();
  });

  // CREATE: INSERT lalu kembalikan baris baru (id & created_at dari database).
  @override
  Future<SavedBook> create(SavedBook book) => _run('menyimpan buku', () async {
    final row = await _table.insert(book.toJson()).select().single();
    return SavedBook.fromJson(row);
  });

  // UPDATE berdasarkan id. select() memastikan baris benar-benar berubah
  // (jika id tidak ada / ditolak RLS, Supabase tidak menganggapnya error).
  @override
  Future<SavedBook> update(SavedBook book) =>
      _run('memperbarui data', () async {
        final id = book.id;
        if (id == null) throw StateError('Data belum memiliki id');
        final rows = await _table
            .update({
              ...book.toJson(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id)
            .select();
        if (rows.isEmpty) {
          throw StateError('Data tidak ditemukan atau tidak boleh diubah.');
        }
        return SavedBook.fromJson(rows.first);
      });

  // DELETE berdasarkan id, dengan pengecekan baris yang benar-benar terhapus.
  @override
  Future<void> delete(int id) => _run('menghapus data', () async {
    final rows = await _table.delete().eq('id', id).select();
    if (rows.isEmpty) {
      throw StateError('Data tidak ditemukan atau tidak boleh dihapus.');
    }
  });
}
