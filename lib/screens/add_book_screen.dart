import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/book.dart';
import '../models/saved_book.dart';
import '../providers/collection_provider.dart';
import '../widgets/responsive.dart';
import '../widgets/saved_book_form.dart';

// Create: menambahkan buku dari katalog API ke koleksi (INSERT database).
class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key, required this.book});

  final Book book;

  Future<void> _save(BuildContext context, SavedBook data) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<CollectionProvider>().add(data);
      messenger.showSnackBar(
        SnackBar(content: Text('"${data.title}" ditambahkan ke koleksi')),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah ke Koleksi')),
      body: MaxWidth(
        maxWidth: 720,
        child: SavedBookForm(
          initial: SavedBook.fromBook(book),
          submitLabel: 'Simpan ke Koleksi',
          onSubmit: (data) => _save(context, data),
        ),
      ),
    );
  }
}
