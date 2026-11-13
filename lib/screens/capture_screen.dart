import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learning_item.dart';
import '../providers/library_provider.dart';
import '../widgets/learning_item_form.dart';
import '../widgets/responsive.dart';

// Capture (Create): menyimpan temuan baru ke Learning Library.
// Bisa input manual, atau sudah terisi dari hasil Discover (Open Library).
class CaptureScreen extends StatelessWidget {
  const CaptureScreen({super.key, this.initial});

  final LearningItem? initial;

  Future<void> _save(BuildContext context, LearningItem item) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      final created = await context.read<LibraryProvider>().add(item);
      messenger.showSnackBar(
        SnackBar(content: Text('"${created.title}" disimpan ke Library')),
      );
      navigator.pop(created);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = context.read<LibraryProvider>().topics;
    return Scaffold(
      appBar: AppBar(
        title: Text(initial == null ? 'Capture Item' : 'Simpan dari Discover'),
      ),
      body: MaxWidth(
        maxWidth: 760,
        child: LearningItemForm(
          initial: initial ?? const LearningItem(title: ''),
          submitLabel: 'Simpan ke Library',
          topicSuggestions: topics,
          onSubmit: (item) => _save(context, item),
        ),
      ),
    );
  }
}
