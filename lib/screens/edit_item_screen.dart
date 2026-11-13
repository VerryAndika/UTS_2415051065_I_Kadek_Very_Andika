import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learning_item.dart';
import '../providers/library_provider.dart';
import '../widgets/learning_item_form.dart';
import '../widgets/responsive.dart';

// Edit (Update): mengubah profil, status, catatan, dan rating item.
class EditItemScreen extends StatelessWidget {
  const EditItemScreen({super.key, required this.item});

  final LearningItem item;

  Future<void> _save(BuildContext context, LearningItem data) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<LibraryProvider>().update(data);
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
      appBar: AppBar(title: const Text('Edit Item')),
      body: MaxWidth(
        maxWidth: 760,
        child: LearningItemForm(
          initial: item,
          submitLabel: 'Simpan Perubahan',
          topicSuggestions: context.read<LibraryProvider>().topics,
          onSubmit: (data) => _save(context, data),
        ),
      ),
    );
  }
}
