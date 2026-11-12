import 'package:flutter/material.dart';

import '../models/book.dart';
import '../widgets/book_cover.dart';
import '../widgets/responsive.dart';

// Detail buku: menerima objek Book dari layar sebelumnya lewat constructor.
class BookDetailScreen extends StatelessWidget {
  const BookDetailScreen({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
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
