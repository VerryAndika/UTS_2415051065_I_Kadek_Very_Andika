import 'package:flutter/material.dart' show IconData, Icons;

// Status baca yang disimpan di kolom `status` tabel saved_books.
enum ReadingStatus {
  want('want', 'Ingin dibaca', Icons.bookmark_add),
  reading('reading', 'Sedang dibaca', Icons.auto_stories),
  done('done', 'Selesai', Icons.task_alt);

  const ReadingStatus(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  static ReadingStatus fromValue(String? value) => ReadingStatus.values
      .firstWhere((s) => s.value == value, orElse: () => ReadingStatus.want);
}
