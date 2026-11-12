import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/book.dart';
import '../models/reading_status.dart';
import '../providers/book_provider.dart';
import '../providers/collection_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/reading_stats_card.dart';
import '../widgets/responsive.dart';
import '../widgets/saved_book_tile.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';
import 'book_detail_screen.dart';
import 'saved_book_detail_screen.dart';

// Home/Dashboard: identitas, pencarian cepat, statistik bacaan,
// buku yang sedang dibaca (database), dan rekomendasi (REST API).
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
    final reading = collection.currentlyReading.take(compact ? 2 : 4).toList();

    Widget bookAt(BuildContext context, int i) {
      final Book book = recommended[i];
      return BookCard(
        title: book.title,
        author: book.authorText,
        coverUrl: book.coverUrl(),
        subtitle: book.firstPublishYear?.toString(),
        trailing: collection.isSaved(book.key)
            ? const Icon(Icons.bookmark, size: 18)
            : null,
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
      recommendations = Card(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: ListTile(
          leading: const Icon(Icons.wifi_off_rounded),
          title: const Text('Rekomendasi gagal dimuat'),
          subtitle: Text(books.recommendedError!),
          trailing: TextButton(
            onPressed: books.loadRecommendations,
            child: const Text('Coba lagi'),
          ),
        ),
      );
    } else if (recommended.isEmpty) {
      recommendations = const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Belum ada rekomendasi.'),
      );
    } else if (compact) {
      // Compact: list horizontal; layar lebar: grid responsif.
      recommendations = SizedBox(
        height: 260,
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
        itemCount: recommended.length.clamp(0, 12),
        itemBuilder: bookAt,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_stories),
            SizedBox(width: 8),
            Text(AppConfig.appName),
          ],
        ),
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
      body: RefreshIndicator(
        onRefresh: () =>
            Future.wait([collection.load(), books.loadRecommendations()]),
        child: MaxWidth(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              _GreetingCard(onSearch: onOpenCatalog),
              const SectionHeader(title: 'Statistik Bacaan'),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ReadingStatsCard(
                  total: collection.items.length,
                  done: collection.countByStatus(ReadingStatus.done),
                  pagesRead: collection.pagesRead,
                  averageRating: collection.averageRating,
                ),
              ),
              if (reading.isNotEmpty) ...[
                const SectionHeader(title: 'Sedang Dibaca'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: compact ? 1 : 2,
                      mainAxisExtent: SavedBookTile.height,
                    ),
                    itemCount: reading.length,
                    itemBuilder: (context, i) => SavedBookTile(
                      book: reading[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              SavedBookDetailScreen(bookId: reading[i].id!),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              SectionHeader(
                title: 'Rekomendasi',
                action: 'Lihat semua',
                onAction: onOpenCatalog,
              ),
              recommendations,
            ],
          ),
        ),
      ),
    );
  }
}

class _GreetingCard extends StatelessWidget {
  const _GreetingCard({this.onSearch});

  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: scheme.primary,
                foregroundColor: scheme.onPrimary,
                child: const Text('VA'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${AppConfig.studentName}',
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '${AppConfig.studentId} • Kelas ${AppConfig.studentClass}',
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            readOnly: true,
            onTap: onSearch,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Mau baca apa hari ini?',
              filled: true,
              fillColor: scheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
