import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../models/sample_books.dart';
import '../widgets/book_card.dart';
import '../widgets/responsive.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'book_detail_screen.dart';

// Home/Dashboard: sapaan, pencarian cepat, ringkasan koleksi, rekomendasi.
// (Data masih dummy; akan diganti REST API & database pada tahap berikutnya.)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenCatalog});

  // Callback dari HomeShell untuk pindah ke tab Katalog.
  final VoidCallback? onOpenCatalog;

  static const _stats = [
    ('Ingin dibaca', '0', Icons.bookmark_add),
    ('Sedang dibaca', '0', Icons.auto_stories),
    ('Selesai', '0', Icons.task_alt),
    ('Rata-rata rating', '-', Icons.star),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);

    Widget bookAt(BuildContext context, int i) => BookCard(
      title: sampleBooks[i].title,
      author: sampleBooks[i].authorText,
      coverUrl: sampleBooks[i].coverUrl(),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookDetailScreen(book: sampleBooks[i]),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text(AppConfig.appName)),
      body: MaxWidth(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${AppConfig.studentName}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const Text(
                    '${AppConfig.studentId} • ${AppConfig.studentClass}',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    readOnly: true,
                    onTap: onOpenCatalog,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Cari judul atau penulis...',
                    ),
                  ),
                ],
              ),
            ),
            const SectionHeader(title: 'Koleksi Saya'),
            // Compact: grid 2 kolom; layar lebar: 4 kartu dalam satu baris.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GridView.count(
                crossAxisCount: compact ? 2 : 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: compact ? 2.1 : 2.6,
                children: [
                  for (final (label, value, icon) in _stats)
                    StatCard(label: label, value: value, icon: icon),
                ],
              ),
            ),
            SectionHeader(
              title: 'Rekomendasi',
              action: 'Lihat semua',
              onAction: onOpenCatalog,
            ),
            // Compact: list horizontal; layar lebar: grid responsif.
            if (compact)
              SizedBox(
                height: 250,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: sampleBooks.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 4),
                  itemBuilder: (context, i) =>
                      SizedBox(width: 150, child: bookAt(context, i)),
                ),
              )
            else
              ResponsiveGrid(
                shrinkWrap: true,
                minItemWidth: 170,
                itemCount: sampleBooks.length,
                itemBuilder: bookAt,
              ),
          ],
        ),
      ),
    );
  }
}
