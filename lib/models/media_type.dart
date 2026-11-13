import 'package:flutter/material.dart' show IconData, Icons;

// Jenis media sebuah Learning Item. Berbeda dengan topik (bidang
// pengetahuan): buku dan video bisa sama-sama bertopik "Psychology".
enum MediaType {
  book('book', 'Buku', 'Books', Icons.menu_book_rounded),
  article('article', 'Artikel', 'Articles', Icons.article_outlined),
  video('video', 'Video', 'Videos', Icons.smart_display_outlined),
  course('course', 'Course', 'Courses', Icons.school_outlined),
  game('game', 'Game', 'Games', Icons.sports_esports_outlined),
  podcast('podcast', 'Podcast', 'Podcasts', Icons.podcasts_rounded),
  research('research', 'Riset', 'Research', Icons.science_outlined),
  other('other', 'Lainnya', 'Other', Icons.lightbulb_outline);

  const MediaType(this.value, this.label, this.plural, this.icon);

  final String value;
  final String label;
  final String plural;
  final IconData icon;

  static MediaType fromValue(String? value) => MediaType.values.firstWhere(
    (m) => m.value == value,
    orElse: () => MediaType.other,
  );
}
