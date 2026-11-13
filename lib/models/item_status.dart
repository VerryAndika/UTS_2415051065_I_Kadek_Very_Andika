import 'package:flutter/material.dart' show Color, IconData, Icons;

// Status eksplorasi (Learning Queue).
enum ItemStatus {
  inbox(
    'inbox',
    'Inbox',
    'Baru disimpan, belum dipilah',
    Icons.inbox_outlined,
    Color(0xFF64748B),
  ),
  want(
    'want',
    'Want to Explore',
    'Ingin dipelajari',
    Icons.bookmark_add_outlined,
    Color(0xFFB45309),
  ),
  progress(
    'progress',
    'In Progress',
    'Sedang dieksplorasi',
    Icons.timelapse_rounded,
    Color(0xFF2563EB),
  ),
  done(
    'done',
    'Completed',
    'Sudah dipelajari',
    Icons.task_alt_rounded,
    Color(0xFF15803D),
  );

  const ItemStatus(this.value, this.label, this.hint, this.icon, this.color);

  final String value;
  final String label;
  final String hint;
  final IconData icon;
  final Color color;

  static ItemStatus fromValue(String? value) => ItemStatus.values.firstWhere(
    (s) => s.value == value,
    orElse: () => ItemStatus.inbox,
  );
}
