import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../providers/collection_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/responsive.dart';
import '../widgets/state_views.dart';
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

  static const _categories = [
    ('Pemrograman', 'programming'),
    ('Fiksi', 'fiction'),
    ('Sains', 'science'),
    ('Sejarah', 'history'),
    ('Bisnis', 'business'),
    ('Indonesia', 'indonesia'),
  ];

  void _search(String query) {
    FocusScope.of(context).unfocus();
    context.read<BookProvider>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();
    final collection = context.watch<CollectionProvider>();

    Widget body;
    if (provider.isLoading) {
      body = LoadingView(message: 'Mencari "${provider.query}"...');
    } else if (provider.error != null) {
      body = ErrorView(
        message: provider.error!,
        isNetwork: provider.errorIsNetwork,
        onRetry: provider.retry,
      );
    } else if (provider.results.isEmpty) {
      body = EmptyView(
        icon: Icons.search_off,
        title: 'Buku tidak ditemukan',
        message:
            'Tidak ada hasil untuk "${provider.query}". '
            'Coba kata kunci lain.',
      );
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
              onSubmitted: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari judul atau penulis...',
                suffixIcon: IconButton(
                  tooltip: 'Cari',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => _search(_controller.text),
                ),
              ),
            ),
          ),
          // Kategori cepat: tap chip -> cari berdasarkan topik.
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                for (final (label, query) in _categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: provider.query == query,
                      onSelected: (_) {
                        _controller.text = query;
                        _search(query);
                      },
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: context.read<BookProvider>().retry,
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
