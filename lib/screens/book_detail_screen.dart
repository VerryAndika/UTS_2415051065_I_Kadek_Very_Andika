import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../providers/book_provider.dart';
import '../providers/collection_provider.dart';
import '../widgets/book_cover.dart';
import '../widgets/responsive.dart';
import 'add_book_screen.dart';
import 'saved_book_detail_screen.dart';

// Detail buku: menerima objek Book dari layar sebelumnya (passing data),
// lalu memuat deskripsi lengkap lewat BookProvider.
class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Future<Book> _detail;

  @override
  void initState() {
    super.initState();
    _detail = context.read<BookProvider>().getDetail(widget.book);
  }

  Future<void> _openAddForm() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddBookScreen(book: widget.book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final text = Theme.of(context).textTheme;
    final saved = context.watch<CollectionProvider>().findByKey(book.key);

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
                    builder: (_) => SavedBookDetailScreen(bookId: saved.id!),
                  ),
                ),
                icon: const Icon(Icons.bookmark_added),
                label: Text('Di koleksi • ${saved.status.label}'),
              )
            : FilledButton.icon(
                onPressed: _openAddForm,
                icon: const Icon(Icons.bookmark_add),
                label: const Text('Tambah ke Koleksi'),
              ),
        const SizedBox(height: 16),
        FutureBuilder<Book>(
          future: _detail,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LinearProgressIndicator();
            }
            final detail = snapshot.data;
            final description = detail?.description;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Deskripsi', style: text.titleMedium),
                const SizedBox(height: 4),
                Text(
                  description == null || description.isEmpty
                      ? 'Deskripsi belum tersedia.'
                      : description,
                ),
                if (detail != null && detail.subjects.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Subjek', style: text.titleMedium),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final s in detail.subjects)
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
