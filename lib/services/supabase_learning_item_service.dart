import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../models/learning_item.dart';
import 'app_exception.dart';
import 'learning_item_data_source.dart';

// CRUD tabel `learning_items` di Supabase (PostgreSQL).
// Semua error database/jaringan diterjemahkan menjadi AppException.
class SupabaseLearningItemService implements LearningItemDataSource {
  SupabaseLearningItemService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const timeout = Duration(seconds: 15);

  SupabaseQueryBuilder get _table =>
      _client.from(SupabaseConfig.learningItemsTable);

  Future<T> _run<T>(String action, Future<T> Function() query) async {
    try {
      return await query().timeout(timeout);
    } catch (e) {
      throw AppException.from(e, action: action);
    }
  }

  // READ: semua item milik mahasiswa ini, terbaru di atas.
  @override
  Future<List<LearningItem>> getAll() => _run('memuat library', () async {
    final rows = await _table
        .select()
        .eq('student_id', AppConfig.studentId)
        .order('created_at', ascending: false);
    return rows.map(LearningItem.fromJson).toList();
  });

  // CREATE: INSERT lalu kembalikan baris baru.
  @override
  Future<LearningItem> create(LearningItem item) =>
      _run('menyimpan item', () async {
        final row = await _table.insert(item.toJson()).select().single();
        return LearningItem.fromJson(row);
      });

  // UPDATE berdasarkan id + cek baris yang benar-benar berubah.
  @override
  Future<LearningItem> update(LearningItem item) =>
      _run('memperbarui item', () async {
        final id = item.id;
        if (id == null) throw StateError('Item belum memiliki id.');
        final rows = await _table
            .update({
              ...item.toJson(),
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', id)
            .select();
        if (rows.isEmpty) {
          throw StateError('Item tidak ditemukan atau tidak boleh diubah.');
        }
        return LearningItem.fromJson(rows.first);
      });

  // DELETE berdasarkan id + cek baris yang terhapus.
  @override
  Future<void> delete(int id) => _run('menghapus item', () async {
    final rows = await _table.delete().eq('id', id).select();
    if (rows.isEmpty) {
      throw StateError('Item tidak ditemukan atau tidak boleh dihapus.');
    }
  });
}
