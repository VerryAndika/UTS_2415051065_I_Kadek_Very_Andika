import 'package:flutter/material.dart';

import '../models/reading_status.dart';
import '../models/saved_book.dart';
import 'book_cover.dart';
import 'rating_input.dart';

// Reusable widget: form data koleksi (dipakai screen Tambah & Edit).
// Validasi dilakukan di sisi UI; database tetap menegakkan CHECK constraint.
class SavedBookForm extends StatefulWidget {
  const SavedBookForm({
    super.key,
    required this.initial,
    required this.submitLabel,
    required this.onSubmit,
  });

  final SavedBook initial;
  final String submitLabel;

  /// Dipanggil dengan data hasil form yang sudah valid.
  final Future<void> Function(SavedBook book) onSubmit;

  @override
  State<SavedBookForm> createState() => _SavedBookFormState();
}

class _SavedBookFormState extends State<SavedBookForm> {
  final _formKey = GlobalKey<FormState>();
  late ReadingStatus _status = widget.initial.status;
  late int? _rating = widget.initial.rating;
  late final _totalCtrl = TextEditingController(
    text: widget.initial.totalPages?.toString() ?? '',
  );
  late final _pageCtrl = TextEditingController(
    text: widget.initial.currentPage.toString(),
  );
  late final _noteCtrl = TextEditingController(text: widget.initial.note ?? '');
  bool _submitting = false;

  @override
  void dispose() {
    _totalCtrl.dispose();
    _pageCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  int? get _total => int.tryParse(_totalCtrl.text.trim());

  String? _validateTotal(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null; // opsional
    final n = int.tryParse(text);
    if (n == null) return 'Harus berupa angka';
    if (n <= 0) return 'Jumlah halaman harus lebih dari 0';
    if (n > 20000) return 'Jumlah halaman tidak wajar';
    return null;
  }

  String? _validatePage(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Isi 0 jika belum mulai membaca';
    final n = int.tryParse(text);
    if (n == null) return 'Harus berupa angka';
    if (n < 0) return 'Tidak boleh negatif';
    final total = _total;
    if (total != null && n > total) {
      return 'Tidak boleh melebihi jumlah halaman ($total)';
    }
    return null;
  }

  String? _validateNote(String? value) {
    final text = value?.trim() ?? '';
    if (text.isNotEmpty && text.length < 3) return 'Catatan minimal 3 karakter';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final total = _total;
    var page = int.parse(_pageCtrl.text.trim());
    // Status "Selesai" -> halaman terakhir = total halaman.
    if (_status == ReadingStatus.done && total != null) page = total;

    final note = _noteCtrl.text.trim();
    final result = SavedBook(
      id: widget.initial.id,
      bookKey: widget.initial.bookKey,
      title: widget.initial.title,
      author: widget.initial.author,
      coverUrl: widget.initial.coverUrl,
      status: _status,
      rating: _rating,
      note: note.isEmpty ? null : note,
      currentPage: page,
      totalPages: total,
      createdAt: widget.initial.createdAt,
    );

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(result);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              BookCover(url: widget.initial.coverUrl, width: 56, height: 84),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.initial.title, style: text.titleMedium),
                    Text(widget.initial.author, style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Status baca', style: text.labelLarge),
          const SizedBox(height: 8),
          SegmentedButton<ReadingStatus>(
            segments: [
              for (final s in ReadingStatus.values)
                ButtonSegment(
                  value: s,
                  label: Text(s.label),
                  icon: Icon(s.icon),
                ),
            ],
            selected: {_status},
            onSelectionChanged: (v) => setState(() => _status = v.first),
          ),
          const SizedBox(height: 16),
          Text('Rating', style: text.labelLarge),
          RatingInput(
            initialValue: _rating,
            onChanged: (v) => _rating = v,
            validator: (v) => _status == ReadingStatus.done && v == null
                ? 'Beri rating untuk buku yang sudah selesai dibaca'
                : null,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: const Key('field_current_page'),
                  controller: _pageCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Halaman terakhir',
                    prefixIcon: Icon(Icons.bookmark_outline),
                  ),
                  validator: _validatePage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: const Key('field_total_pages'),
                  controller: _totalCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah halaman',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: _validateTotal,
                  onChanged: (_) => _formKey.currentState?.validate(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('field_note'),
            controller: _noteCtrl,
            maxLines: 3,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Catatan / review (opsional)',
              alignLabelWithHint: true,
            ),
            validator: _validateNote,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
