import 'package:flutter/material.dart';

import '../widgets/book_card.dart';
import '../widgets/responsive.dart';
import 'book_detail_screen.dart';

// List/Catalog: daftar buku dalam grid responsif. Tap -> Detail (passing data).
class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  static const dummyBooks = [
    {'title': 'Clean Code', 'author': 'Robert C. Martin', 'year': '2008'},
    {
      'title': 'The Pragmatic Programmer',
      'author': 'Andrew Hunt',
      'year': '1999',
    },
    {'title': 'Atomic Habits', 'author': 'James Clear', 'year': '2018'},
    {'title': 'Laskar Pelangi', 'author': 'Andrea Hirata', 'year': '2005'},
    {
      'title': 'Bumi Manusia',
      'author': 'Pramoedya Ananta Toer',
      'year': '1980',
    },
    {'title': 'Sapiens', 'author': 'Yuval Noah Harari', 'year': '2011'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Buku')),
      body: ResponsiveGrid(
        itemCount: dummyBooks.length,
        itemBuilder: (context, i) {
          final book = dummyBooks[i];
          return BookCard(
            title: book['title']!,
            author: book['author']!,
            subtitle: book['year'],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
            ),
          );
        },
      ),
    );
  }
}
