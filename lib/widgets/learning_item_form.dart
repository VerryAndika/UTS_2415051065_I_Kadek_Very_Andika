import 'package:flutter/material.dart';

import '../models/item_status.dart';
import '../models/learning_item.dart';
import '../models/media_type.dart';
import 'item_visuals.dart';
import 'rating_input.dart';

// Reusable widget: form Learning Item (dipakai Capture & Edit).
// Validasi di UI; database tetap menegakkan CHECK constraint.
class LearningItemForm extends StatefulWidget {
  const LearningItemForm({
    super.key,
    required this.initial,
    required this.submitLabel,
    required this.onSubmit,
    this.topicSuggestions = const [],
  });

  final LearningItem initial;
  final String submitLabel;
  final Future<void> Function(LearningItem item) onSubmit;
  final List<String> topicSuggestions;

  @override
  State<LearningItemForm> createState() => _LearningItemFormState();
}

class _LearningItemFormState extends State<LearningItemForm> {
  final _formKey = GlobalKey<FormState>();
  late MediaType _media = widget.initial.mediaType;
  late ItemStatus _status = widget.initial.status;
  late int? _rating = widget.initial.rating;
  late String _source = widget.initial.source;

  late final _title = TextEditingController(text: widget.initial.title);
  late final _creator = TextEditingController(text: widget.initial.creator);
  late final _url = TextEditingController(text: widget.initial.url);
  late final _topic = TextEditingController(
    text: widget.initial.topic == 'Umum' ? '' : widget.initial.topic,
  );
  late final _sourceCtrl = TextEditingController(
    text: LearningItem.commonSources.contains(widget.initial.source)
        ? ''
        : widget.initial.source,
  );
  late final _description = TextEditingController(
    text: widget.initial.description,
  );
  late final _tags = TextEditingController(
    text: widget.initial.characteristics.join(', '),
  );
  late final _reason = TextEditingController(text: widget.initial.reason);
  late final _notes = TextEditingController(text: widget.initial.notes);
  bool _submitting = false;

  @override
  void dispose() {
    for (final c in [
      _title,
      _creator,
      _url,
      _topic,
      _sourceCtrl,
      _description,
      _tags,
      _reason,
      _notes,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v, String field, {int min = 2}) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return '$field wajib diisi';
    if (t.length < min) return '$field minimal $min karakter';
    return null;
  }

  String? _validateUrl(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null; // opsional
    final uri = Uri.tryParse(t);
    if (uri == null ||
        !(uri.scheme == 'http' || uri.scheme == 'https') ||
        uri.host.isEmpty) {
      return 'Link harus diawali http:// atau https://';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final source = _source == 'Lainnya' ? _sourceCtrl.text.trim() : _source;
    final item = LearningItem(
      id: widget.initial.id,
      title: _title.text.trim(),
      mediaType: _media,
      topic: _topic.text.trim(),
      creator: _creator.text,
      url: _url.text,
      source: source.isEmpty ? 'Manual' : source,
      description: _description.text,
      characteristics: LearningItem.parseTags(_tags.text),
      reason: _reason.text,
      status: _status,
      notes: _notes.text,
      rating: _rating,
      coverUrl: widget.initial.coverUrl,
      externalKey: widget.initial.externalKey,
      createdAt: widget.initial.createdAt,
    );
    setState(() => _submitting = true);
    try {
      await widget.onSubmit(item);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _section(String title, String hint) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(hint, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final sources = [...LearningItem.commonSources, 'Lainnya'];
    final isCustomSource = !LearningItem.commonSources.contains(_source);
    final selectedSource = isCustomSource ? 'Lainnya' : _source;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _section('Jenis media', 'Buku, artikel, video, course, game, ...'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final m in MediaType.values)
                ChoiceChip(
                  avatar: Icon(m.icon, size: 18, color: mediaColor(m)),
                  label: Text(m.label),
                  selected: _media == m,
                  onSelected: (_) => setState(() => _media = m),
                ),
            ],
          ),
          _section('Apa yang ingin dipelajari?', 'Judul dan pembuatnya'),
          TextFormField(
            key: const Key('field_title'),
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Judul *',
              prefixIcon: Icon(Icons.title),
            ),
            validator: (v) => _required(v, 'Judul'),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('field_creator'),
            controller: _creator,
            decoration: const InputDecoration(
              labelText: 'Penulis / channel / penerbit',
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('field_url'),
            controller: _url,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Link (opsional)',
              hintText: 'https://...',
              prefixIcon: Icon(Icons.link),
            ),
            validator: _validateUrl,
          ),
          _section('Topik pengetahuan', 'Berbeda dari jenis media'),
          TextFormField(
            key: const Key('field_topic'),
            controller: _topic,
            decoration: const InputDecoration(
              labelText: 'Topik *',
              hintText: 'mis. Psychology, Computer Science',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            validator: (v) => _required(v, 'Topik'),
          ),
          if (widget.topicSuggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final t in widget.topicSuggestions.take(8))
                  ActionChip(
                    label: Text(t),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => setState(() => _topic.text = t),
                  ),
              ],
            ),
          ],
          _section('Sumber rekomendasi', 'Dari mana kamu menemukannya?'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in sources)
                ChoiceChip(
                  label: Text(s),
                  selected: selectedSource == s,
                  onSelected: (_) => setState(() => _source = s),
                ),
            ],
          ),
          if (selectedSource == 'Lainnya') ...[
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('field_source'),
              controller: _sourceCtrl,
              decoration: const InputDecoration(
                labelText: 'Sumber lain',
                prefixIcon: Icon(Icons.travel_explore),
              ),
              validator: (v) => _required(v, 'Sumber'),
            ),
          ],
          _section(
            'Mengapa disimpan?',
            'Agar enam bulan lagi kamu masih ingat',
          ),
          TextFormField(
            key: const Key('field_reason'),
            controller: _reason,
            maxLines: 3,
            maxLength: 300,
            decoration: const InputDecoration(
              labelText: 'Alasan tertarik *',
              alignLabelWithHint: true,
            ),
            validator: (v) => _required(v, 'Alasan', min: 10),
          ),
          _section('Profil item', 'Deskripsi singkat dan karakteristik'),
          TextFormField(
            key: const Key('field_description'),
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Deskripsi',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            key: const Key('field_tags'),
            controller: _tags,
            decoration: const InputDecoration(
              labelText: 'Karakteristik (pisahkan dengan koma)',
              hintText: 'Nonfiction, Habit, Pemula',
              prefixIcon: Icon(Icons.sell_outlined),
            ),
          ),
          _section('Status eksplorasi', 'Posisi item di Learning Queue'),
          DropdownButtonFormField<ItemStatus>(
            initialValue: _status,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            items: [
              for (final s in ItemStatus.values)
                DropdownMenuItem(
                  value: s,
                  child: Text('${s.label} — ${s.hint}'),
                ),
            ],
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
          _section('Learning notes', 'Ide utama, pertanyaan, refleksi'),
          TextFormField(
            key: const Key('field_notes'),
            controller: _notes,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Catatan / refleksi (opsional)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 8),
          Text('Rating', style: Theme.of(context).textTheme.labelLarge),
          RatingInput(
            initialValue: _rating,
            onChanged: (v) => _rating = v,
            validator: (v) => _status == ItemStatus.done && v == null
                ? 'Beri rating untuk item yang sudah selesai dipelajari'
                : null,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _submitting ? null : _submit,
            icon: _submitting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
