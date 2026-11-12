import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_book.dart';
import '../providers/collection_provider.dart';
import '../widgets/book_cover.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/rating_input.dart';
import '../widgets/responsive.dart';
import 'edit_book_screen.dart';

// Detail item koleksi (data dari database): progress, rating, catatan,
// serta aksi Edit. Menerima id lalu membaca versi terbaru dari provider.
class SavedBookDetailScreen extends StatelessWidget {
  const SavedBookDetailScreen({super.key, required this.bookId});

  final int bookId;

  Future<void> _changePage(
    BuildContext context,
    SavedBook book,
    int delta,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final updated = await context.read<CollectionProvider>().changePage(
        book,
        delta,
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Progress diperbarui: halaman ${updated.currentPage}',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal memperbarui: $e')));
    }
  }

  // DELETE dengan confirmation dialog.
  Future<void> _delete(BuildContext context, SavedBook book) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus dari koleksi?',
      message:
          '"${book.title}" beserta rating dan catatannya akan dihapus '
          'permanen dari database.',
    );
    if (!ok || !context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<CollectionProvider>().remove(book);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('"${book.title}" dihapus dari koleksi')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

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
        const SizedBox(height: 8),
        // Update cepat progress halaman (fitur tambahan).
        Wrap(
          spacing: 8,
          children: [
            for (final delta in const [-10, 10, 25])
              ActionChip(
                avatar: Icon(delta < 0 ? Icons.remove : Icons.add, size: 18),
                label: Text('${delta.abs()} hal'),
                onPressed: () => _changePage(context, book, delta),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Catatan', style: text.titleMedium),
        const SizedBox(height: 4),
        Text(book.note ?? 'Belum ada catatan.'),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => EditBookScreen(book: book)),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => _delete(context, book),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Hapus'),
            ),
          ],
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
