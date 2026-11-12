import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/reading_status.dart';
import '../models/saved_book.dart';
import '../providers/collection_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/responsive.dart';
import '../widgets/saved_book_tile.dart';
import 'edit_book_screen.dart';
import 'saved_book_detail_screen.dart';

// Koleksi Saya: data dari database (CollectionProvider), dengan filter
// status, urutan, pull-to-refresh, swipe-to-delete, dan layout responsif.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context, SavedBook book) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus dari koleksi?',
      message: '"${book.title}" akan dihapus permanen dari database.',
    );
    if (!ok || !context.mounted) return false;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<CollectionProvider>().remove(book);
      messenger.showSnackBar(
        SnackBar(content: Text('"${book.title}" dihapus')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
    // Item hilang karena list provider berubah, bukan animasi Dismissible.
    return false;
  }

  Widget _tile(BuildContext context, SavedBook book) {
    return Dismissible(
      key: ValueKey(book.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Theme.of(context).colorScheme.errorContainer,
        child: const Icon(Icons.delete_outline),
      ),
      confirmDismiss: (_) => _confirmDelete(context, book),
      child: SavedBookTile(
        book: book,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SavedBookDetailScreen(bookId: book.id!),
          ),
        ),
        onEdit: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => EditBookScreen(book: book))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CollectionProvider>();
    final items = provider.visibleItems;

    Widget body;
    if (provider.isLoading && provider.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.error != null) {
      body = ListView(
        children: [
          const SizedBox(height: 120),
          Center(child: Text(provider.error!)),
        ],
      );
    } else if (items.isEmpty) {
      body = ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('Belum ada buku di koleksi.')),
        ],
      );
    } else {
      // Compact: list 1 kolom; layar lebar: 2–3 kolom.
      body = LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1100
              ? 3
              : constraints.maxWidth >= Responsive.compactMax
              ? 2
              : 1;
          if (columns == 1) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              itemCount: items.length,
              itemBuilder: (context, i) => _tile(context, items[i]),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 128,
            ),
            itemCount: items.length,
            itemBuilder: (context, i) => _tile(context, items[i]),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksi Saya'),
        actions: [
          PopupMenuButton<CollectionSort>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort),
            initialValue: provider.sort,
            onSelected: provider.setSort,
            itemBuilder: (_) => [
              for (final s in CollectionSort.values)
                PopupMenuItem(value: s, child: Text(s.label)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                ChoiceChip(
                  label: Text('Semua (${provider.items.length})'),
                  selected: provider.filter == null,
                  onSelected: (_) => provider.setFilter(null),
                ),
                for (final s in ReadingStatus.values)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ChoiceChip(
                      avatar: Icon(s.icon, size: 18),
                      label: Text('${s.label} (${provider.countByStatus(s)})'),
                      selected: provider.filter == s,
                      onSelected: (_) => provider.setFilter(s),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(onRefresh: provider.load, child: body),
          ),
        ],
      ),
    );
  }
}
