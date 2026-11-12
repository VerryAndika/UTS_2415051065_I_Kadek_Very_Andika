import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_book.dart';
import '../providers/collection_provider.dart';
import '../widgets/book_cover.dart';
import '../widgets/rating_input.dart';
import '../widgets/responsive.dart';
import 'edit_book_screen.dart';

// Detail item koleksi (data dari database): progress, rating, catatan,
// serta aksi Edit. Menerima id lalu membaca versi terbaru dari provider.
class SavedBookDetailScreen extends StatelessWidget {
  const SavedBookDetailScreen({super.key, required this.bookId});

  final int bookId;

  @override
  Widget build(BuildContext context) {
    final SavedBook? book = context.watch<CollectionProvider>().findById(
      bookId,
    );
    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Data tidak ditemukan.')),
      );
    }

    final text = Theme.of(context).textTheme;
    final progress = book.progress;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(book.title, style: text.headlineSmall),
        Text(book.author, style: text.titleMedium),
        const SizedBox(height: 12),
        Chip(
          avatar: Icon(book.status.icon, size: 18),
          label: Text(book.status.label),
        ),
        const SizedBox(height: 8),
        RatingStars(rating: book.rating, size: 24),
        const SizedBox(height: 16),
        Text('Progress baca', style: text.titleMedium),
        const SizedBox(height: 6),
        if (progress != null) ...[
          LinearProgressIndicator(value: progress, minHeight: 10),
          const SizedBox(height: 4),
          Text(
            'Halaman ${book.currentPage} dari ${book.totalPages} '
            '(${(progress * 100).round()}%)',
          ),
        ] else
          Text('Halaman terakhir: ${book.currentPage}'),
        const SizedBox(height: 16),
        Text('Catatan', style: text.titleMedium),
        const SizedBox(height: 4),
        Text(book.note ?? 'Belum ada catatan.'),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => EditBookScreen(book: book))),
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Koleksi')),
      body: MaxWidth(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (Responsive.isCompact(context)) ...[
              Center(
                child: BookCover(url: book.coverUrl, width: 140, height: 210),
              ),
              const SizedBox(height: 16),
              info,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(url: book.coverUrl, width: 180, height: 270),
                  const SizedBox(width: 24),
                  Expanded(child: info),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
