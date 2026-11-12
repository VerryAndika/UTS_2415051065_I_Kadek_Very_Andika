import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/book.dart';
import '../models/reading_status.dart';
import '../providers/book_provider.dart';
import '../providers/collection_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/responsive.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'book_detail_screen.dart';

// Home/Dashboard: sapaan, pencarian cepat, ringkasan koleksi, rekomendasi.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onOpenCatalog});

  // Callback dari HomeShell untuk pindah ke tab Katalog.
  final VoidCallback? onOpenCatalog;

  @override
  Widget build(BuildContext context) {
    final compact = Responsive.isCompact(context);
    final books = context.watch<BookProvider>();
    final collection = context.watch<CollectionProvider>();
    final recommended = books.recommended;

    Widget bookAt(BuildContext context, int i) {
      final Book book = recommended[i];
      return BookCard(
        title: book.title,
        author: book.authorText,
        coverUrl: book.coverUrl(),
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => BookDetailScreen(book: book))),
      );
    }

    final stats = [
      for (final s in ReadingStatus.values)
        StatCard(
          label: s.label,
          value: '${collection.countByStatus(s)}',
          icon: s.icon,
        ),
      StatCard(
        label: 'Total koleksi',
        value: '${collection.items.length}',
        icon: Icons.collections_bookmark,
      ),
    ];

    Widget recommendations;
    if (books.isLoadingRecommended) {
      recommendations = const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (books.recommendedError != null) {
      recommendations = Padding(
        padding: const EdgeInsets.all(16),
        child: Text(books.recommendedError!),
      );
    } else if (compact) {
      recommendations = SizedBox(
        height: 250,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: recommended.length,
          separatorBuilder: (_, _) => const SizedBox(width: 4),
          itemBuilder: (context, i) =>
              SizedBox(width: 150, child: bookAt(context, i)),
        ),
      );
    } else {
      recommendations = ResponsiveGrid(
        shrinkWrap: true,
        minItemWidth: 170,
        itemCount: recommended.length,
        itemBuilder: bookAt,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConfig.appName),
        actions: [
          IconButton(
            tooltip: 'Ganti tema',
            icon: Icon(
              context.watch<ThemeProvider>().isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: context.read<ThemeProvider>().toggle,
          ),
        ],
      ),
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
                children: stats,
              ),
            ),
            SectionHeader(
              title: 'Rekomendasi',
              action: 'Lihat semua',
              onAction: onOpenCatalog,
            ),
            recommendations,
          ],
        ),
      ),
    );
  }
}
