import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/sample_books.dart';
import '../widgets/book_card.dart';
import '../widgets/responsive.dart';
import 'book_detail_screen.dart';

// List/Catalog: daftar buku dalam grid responsif. Tap -> Detail (passing data).
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const List<Book> books = sampleBooks;
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Buku')),
      body: ResponsiveGrid(
        itemCount: books.length,
        itemBuilder: (context, i) {
          final book = books[i];
          return BookCard(
            title: book.title,
            author: book.authorText,
            coverUrl: book.coverUrl(),
            subtitle: book.firstPublishYear?.toString(),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
            ),
          );
        },
      ),
    );
  }
}
