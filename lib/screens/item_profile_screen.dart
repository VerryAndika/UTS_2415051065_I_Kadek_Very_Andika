import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/item_status.dart';
import '../models/learning_item.dart';
import '../models/topic_summary.dart';
import '../providers/library_provider.dart';
import '../providers/topic_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/item_visuals.dart';
import '../widgets/rating_input.dart';
import '../widgets/responsive.dart';
import 'edit_item_screen.dart';

// Item Profile: semua informasi sebuah Learning Item — karakteristik,
// sumber, alasan disimpan, catatan, status eksplorasi, dan ringkasan
// topik dari Wikipedia. Menerima id lalu membaca versi terbaru dari provider.
class ItemProfileScreen extends StatelessWidget {
  const ItemProfileScreen({super.key, required this.itemId});

  final int itemId;

  Future<void> _delete(BuildContext context, LearningItem item) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus dari Library?',
      message:
          '"${item.title}" beserta alasan dan catatannya akan dihapus '
          'permanen dari database.',
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      await context.read<LibraryProvider>().remove(item);
      navigator.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('"${item.title}" dihapus dari Library')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  Future<void> _setStatus(
    BuildContext context,
    LearningItem item,
    ItemStatus status,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<LibraryProvider>().setStatus(item, status);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Status: ${status.label}'),
            duration: const Duration(seconds: 1),
          ),
        );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = context.watch<LibraryProvider>().findById(itemId);
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Item tidak ditemukan.')),
      );
    }
    final text = Theme.of(context).textTheme;
    final compact = Responsive.isCompact(context);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            Pill.media(item.mediaType),
            Pill(label: item.topic, icon: Icons.category_outlined),
            Pill.status(item.status),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          item.title,
          style: text.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if ((item.creator ?? '').isNotEmpty)
          Text(item.creator!, style: text.titleMedium),
        if (item.rating != null) ...[
          const SizedBox(height: 6),
          RatingStars(rating: item.rating, size: 22),
        ],
      ],
    );

    final body = <Widget>[
      _InfoCard(
        icon: Icons.psychology_alt_outlined,
        title: 'Mengapa disimpan?',
        highlight: true,
        child: Text(
          (item.reason ?? '').isEmpty ? 'Belum ada alasan.' : item.reason!,
        ),
      ),
      _InfoCard(
        icon: Icons.explore_outlined,
        title: 'Status eksplorasi',
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in ItemStatus.values)
              ChoiceChip(
                avatar: Icon(
                  s.icon,
                  size: 18,
                  color: item.status == s ? null : s.color,
                ),
                label: Text(s.label),
                selected: item.status == s,
                selectedColor: s.color.withValues(alpha: 0.2),
                onSelected: (_) {
                  if (item.status != s) _setStatus(context, item, s);
                },
              ),
          ],
        ),
      ),
      if ((item.description ?? '').isNotEmpty ||
          item.characteristics.isNotEmpty)
        _InfoCard(
          icon: Icons.info_outline,
          title: 'Karakteristik',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((item.description ?? '').isNotEmpty) Text(item.description!),
              if (item.characteristics.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final c in item.characteristics)
                      Chip(
                        label: Text(c),
                        visualDensity: VisualDensity.compact,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      _InfoCard(
        icon: Icons.travel_explore,
        title: 'Sumber rekomendasi',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.source,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if ((item.url ?? '').isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      item.url!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Salin link',
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.url!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link disalin')),
                      );
                    },
                  ),
                ],
              ),
            if (item.createdAt != null)
              Text('Disimpan ${_date(item.createdAt!)}', style: text.bodySmall),
          ],
        ),
      ),
      _InfoCard(
        icon: Icons.edit_note,
        title: 'Learning notes',
        child: Text(
          (item.notes ?? '').isEmpty
              ? 'Belum ada catatan. Tambahkan ide utama, pertanyaan, atau '
                    'refleksi setelah mempelajarinya.'
              : item.notes!,
        ),
      ),
      _TopicCard(topic: item.topic),
      const SizedBox(height: 8),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => EditItemScreen(item: item)),
            ),
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _delete(context, item),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hapus'),
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Item Profile')),
      body: MaxWidth(
        maxWidth: 1000,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: compact
              ? [
                  Center(child: ItemThumb(item: item, width: 150, height: 210)),
                  const SizedBox(height: 16),
                  header,
                  const SizedBox(height: 12),
                  ...body,
                ]
              : [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ItemThumb(item: item, width: 190, height: 270),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            header,
                            const SizedBox(height: 12),
                            ...body,
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
        ),
      ),
    );
  }

  static String _date(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final l = d.toLocal();
    return '${l.day} ${m[l.month - 1]} ${l.year}';
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.child,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: highlight ? scheme.secondaryContainer : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

// Ringkasan topik dari Wikipedia (REST API kedua).
class _TopicCard extends StatefulWidget {
  const _TopicCard({required this.topic});

  final String topic;

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  late Future<TopicSummary?> _future;

  @override
  void initState() {
    super.initState();
    _future = context.read<TopicProvider>().summaryFor(widget.topic);
  }

  @override
  void didUpdateWidget(covariant _TopicCard old) {
    super.didUpdateWidget(old);
    if (old.topic != widget.topic) {
      _future = context.read<TopicProvider>().summaryFor(widget.topic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      icon: Icons.public,
      title: 'Tentang topik "${widget.topic}"',
      child: FutureBuilder<TopicSummary?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const LinearProgressIndicator();
          }
          if (snap.hasError) {
            return Row(
              children: [
                Expanded(child: Text('${snap.error}')),
                TextButton(
                  onPressed: () => setState(() {
                    _future = context.read<TopicProvider>().retry(widget.topic);
                  }),
                  child: const Text('Coba lagi'),
                ),
              ],
            );
          }
          final s = snap.data;
          if (s == null) {
            return const Text('Ringkasan topik belum tersedia di Wikipedia.');
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (s.thumbnailUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    s.thumbnailUrl!,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, st) => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.extract,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sumber: Wikipedia — ${s.title}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
