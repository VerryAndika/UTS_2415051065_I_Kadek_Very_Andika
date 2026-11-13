import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/learning_item.dart';
import '../providers/book_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/book_cover.dart';
import '../widgets/responsive.dart';
import 'capture_screen.dart';
import 'item_profile_screen.dart';

// Detail buku dari Discover (passing data objek Book). Deskripsi & subjek
// dimuat lewat BookProvider; tombol simpan membuka Capture yang sudah terisi.
class DiscoverDetailScreen extends StatefulWidget {
  const DiscoverDetailScreen({super.key, required this.book});

  final Book book;

  @override
  State<DiscoverDetailScreen> createState() => _DiscoverDetailScreenState();
}

class _DiscoverDetailScreenState extends State<DiscoverDetailScreen> {
  late Future<Book> _detail;

  @override
  void initState() {
    super.initState();
    _detail = context.read<BookProvider>().getDetail(widget.book);
  }

  Future<void> _capture() async {
    Book data = widget.book;
    try {
      data = await _detail; // pakai deskripsi & subjek jika sudah ada
    } catch (_) {}
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CaptureScreen(initial: LearningItem.fromBook(data)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final text = Theme.of(context).textTheme;
    final saved = context.watch<LibraryProvider>().findByExternalKey(book.key);

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(book.title, style: text.headlineSmall),
        const SizedBox(height: 4),
        Text(book.authorText, style: text.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (book.firstPublishYear != null)
              Chip(
                avatar: const Icon(Icons.event, size: 18),
                label: Text('Terbit ${book.firstPublishYear}'),
              ),
            if (book.pageCount != null)
              Chip(
                avatar: const Icon(Icons.description, size: 18),
                label: Text('${book.pageCount} halaman'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        saved != null
            ? FilledButton.tonalIcon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ItemProfileScreen(itemId: saved.id!),
                  ),
                ),
                icon: const Icon(Icons.bookmark_added),
                label: Text('Di Library • ${saved.status.label}'),
              )
            : FilledButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Simpan ke Library'),
              ),
        const SizedBox(height: 16),
        FutureBuilder<Book>(
          future: _detail,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }
            if (snap.hasError) {
              return Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: ListTile(
                  leading: const Icon(Icons.error_outline),
                  title: const Text('Deskripsi gagal dimuat'),
                  subtitle: Text('${snap.error}'),
                  trailing: TextButton(
                    onPressed: () => setState(() {
                      _detail = context.read<BookProvider>().getDetail(book);
                    }),
                    child: const Text('Coba lagi'),
                  ),
                ),
              );
            }
            final d = snap.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deskripsi', style: text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  (d.description ?? '').isEmpty
                      ? 'Deskripsi belum tersedia.'
                      : d.description!,
                ),
                if (d.subjects.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Topik', style: text.titleMedium),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in d.subjects)
                        Chip(
                          label: Text(s),
                          visualDensity: VisualDensity.compact,
                        ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Buku')),
      body: MaxWidth(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (Responsive.isCompact(context)) ...[
              Center(
                child: BookCover(
                  url: book.coverUrl('L'),
                  width: 160,
                  height: 240,
                ),
              ),
              const SizedBox(height: 16),
              info,
            ] else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BookCover(url: book.coverUrl('L'), width: 200, height: 300),
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
