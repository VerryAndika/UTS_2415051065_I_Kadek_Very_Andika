import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../providers/collection_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/responsive.dart';
import 'book_detail_screen.dart';

// List/Catalog: pencarian + grid responsif. Data dari BookProvider.
class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final _controller = TextEditingController(text: BookProvider.defaultQuery);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final collection = context.watch<CollectionProvider>();

    Widget body;
    if (provider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.error != null) {
      body = Center(child: Text(provider.error!));
    } else {
      final books = provider.results;
      body = ResponsiveGrid(
        itemCount: books.length,
        itemBuilder: (context, i) {
          final book = books[i];
          return BookCard(
            title: book.title,
            author: book.authorText,
            coverUrl: book.coverUrl(),
            subtitle: book.firstPublishYear?.toString(),
            trailing: collection.isSaved(book.key)
                ? const Icon(Icons.bookmark, size: 20)
                : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookDetailScreen(book: book)),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Katalog Buku')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (q) => context.read<BookProvider>().search(q),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari judul atau penulis...',
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
