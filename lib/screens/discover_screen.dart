import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/book_provider.dart';
import '../providers/library_provider.dart';
import '../widgets/book_card.dart';
import '../widgets/responsive.dart';
import '../widgets/state_views.dart';
import 'discover_detail_screen.dart';

// Discover: menemukan buku dari REST API Open Library, lalu menyimpannya
// ke Learning Library. Grid responsif + chip topik cepat.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _controller = TextEditingController(text: BookProvider.defaultQuery);

  static const _topics = [
    ('Psychology', 'psychology'),
    ('Programming', 'programming'),
    ('Philosophy', 'philosophy'),
    ('Science', 'science'),
    ('History', 'history'),
    ('Productivity', 'productivity'),
    ('Economics', 'economics'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String q) {
    FocusScope.of(context).unfocus();
    context.read<BookProvider>().search(q);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookProvider>();
    final library = context.watch<LibraryProvider>();

    Widget body;
    if (p.isLoading) {
      body = LoadingView(message: 'Mencari "${p.query}" di Open Library...');
    } else if (p.error != null) {
      body = ErrorView(
        message: p.error!,
        isNetwork: p.errorIsNetwork,
        onRetry: p.retry,
      );
    } else if (p.results.isEmpty) {
      body = EmptyView(
        icon: Icons.search_off,
        title: 'Tidak ditemukan',
        message: 'Tidak ada hasil untuk "${p.query}". Coba kata kunci lain.',
      );
    } else {
      final books = p.results;
      body = ResponsiveGrid(
        itemCount: books.length,
        itemBuilder: (context, i) {
          final book = books[i];
          final saved = library.findByExternalKey(book.key) != null;
          return BookCard(
            title: book.title,
            author: book.authorText,
            coverUrl: book.coverUrl(),
            subtitle: book.firstPublishYear?.toString(),
            trailing: saved
                ? const Tooltip(
                    message: 'Sudah di Library',
                    child: Icon(Icons.bookmark_added, size: 20),
                  )
                : null,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DiscoverDetailScreen(book: book),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Discover')),
      body: MaxWidth(
        maxWidth: 1400,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _search,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.travel_explore),
                  hintText: 'Cari buku untuk dipelajari...',
                  suffixIcon: IconButton(
                    tooltip: 'Cari',
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _search(_controller.text),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  for (final (label, q) in _topics)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: p.query == q,
                        onSelected: (_) {
                          _controller.text = q;
                          _search(q);
                        },
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(onRefresh: p.retry, child: body),
            ),
          ],
        ),
      ),
    );
  }
}
