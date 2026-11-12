import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/saved_book.dart';
import '../providers/collection_provider.dart';
import '../widgets/responsive.dart';
import '../widgets/saved_book_form.dart';

// Edit: mengubah status, rating, halaman, dan catatan (UPDATE database).
class EditBookScreen extends StatelessWidget {
  const EditBookScreen({super.key, required this.book});

  final SavedBook book;

  Future<void> _save(BuildContext context, SavedBook data) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<CollectionProvider>().update(data);
      messenger.showSnackBar(
        const SnackBar(content: Text('Perubahan disimpan')),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Koleksi')),
      body: MaxWidth(
        maxWidth: 720,
        child: SavedBookForm(
          initial: book,
          submitLabel: 'Simpan Perubahan',
          onSubmit: (data) => _save(context, data),
        ),
      ),
    );
  }
}
