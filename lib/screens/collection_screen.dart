import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/collection_provider.dart';
import '../widgets/book_cover.dart';
import 'edit_book_screen.dart';
import 'saved_book_detail_screen.dart';

// Koleksi Saya: daftar buku tersimpan dari CollectionProvider (shared state).
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();

    Widget body;
    if (provider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.error != null) {
      body = Center(child: Text(provider.error!));
    } else if (provider.items.isEmpty) {
      body = const Center(child: Text('Belum ada buku di koleksi.'));
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: provider.items.length,
        itemBuilder: (context, i) {
          final book = provider.items[i];
          return Card(
            child: ListTile(
              leading: BookCover(url: book.coverUrl, width: 40, height: 60),
              title: Text(book.title),
              subtitle: Text('${book.author} • ${book.status.label}'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SavedBookDetailScreen(bookId: book.id!),
                ),
              ),
              trailing: IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EditBookScreen(book: book)),
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi Saya')),
      body: body,
    );
  }
}
