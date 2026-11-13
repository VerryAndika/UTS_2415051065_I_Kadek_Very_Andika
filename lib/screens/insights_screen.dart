import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_status.dart';
import '../models/media_type.dart';
import '../providers/library_provider.dart';
import '../widgets/item_visuals.dart';
import '../widgets/responsive.dart';
import '../widgets/section_header.dart';
import '../widgets/state_views.dart';

// Knowledge Overview: bidang yang paling sering dieksplorasi, jenis media,
// sumber rekomendasi, dan perkembangan status belajar.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, this.onOpenTopic});

  /// Dipanggil saat topik diketuk (HomeShell membuka Library terfilter).
  final void Function(String topic)? onOpenTopic;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final compact = Responsive.isCompact(context);

    if (p.isLoading && p.items.isEmpty) {
      return const Scaffold(body: LoadingView());
    }
    if (p.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Insights')),
        body: const EmptyView(
          icon: Icons.insights,
          title: 'Belum ada data',
          message: 'Insights muncul setelah kamu menyimpan beberapa item.',
        ),
      );
    }

    final total = p.items.length;
    final topics = p.topicCounts.take(8).toList();
    final sources = p.sourceCounts.take(6).toList();

    final summary = GridView.count(
      crossAxisCount: compact ? 2 : 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: compact ? 1.9 : 2.4,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      children: [
        _Metric('$total', 'Item tersimpan', Icons.local_library_outlined),
        _Metric(
          '${p.topicCounts.length}',
          'Topik dieksplorasi',
          Icons.hub_outlined,
        ),
        _Metric(
          '${(p.completionRate * 100).round()}%',
          'Sudah dipelajari',
          Icons.task_alt_rounded,
        ),
        _Metric('${p.itemsWithNotes}', 'Punya catatan', Icons.edit_note),
      ],
    );

    final topicCard = _Panel(
      title: 'Topik paling diminati',
      subtitle: 'Ketuk topik untuk melihat item-nya',
      child: Column(
        children: [
          for (final t in topics)
            _Bar(
              label: t.key,
              value: t.value,
              max: topics.first.value,
              color: Theme.of(context).colorScheme.primary,
              onTap: onOpenTopic == null ? null : () => onOpenTopic!(t.key),
            ),
        ],
      ),
    );

    final mediaCard = _Panel(
      title: 'Jenis media',
      subtitle: 'Dari mana pengetahuanmu berasal',
      child: Column(
        children: [
          for (final m in MediaType.values)
            if (p.countByMedia(m) > 0)
              _Bar(
                label: m.plural,
                icon: m.icon,
                value: p.countByMedia(m),
                max: total,
                color: mediaColor(m),
              ),
        ],
      ),
    );

    final statusCard = _Panel(
      title: 'Perjalanan belajar',
      subtitle: 'Sebaran item di Learning Queue',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 18,
              child: Row(
                children: [
                  for (final s in ItemStatus.values)
                    if (p.countByStatus(s) > 0)
                      Expanded(
                        flex: p.countByStatus(s),
                        child: Container(color: s.color),
                      ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final s in ItemStatus.values)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 10, color: s.color),
                    const SizedBox(width: 4),
                    Text('${s.label}: ${p.countByStatus(s)}'),
                  ],
                ),
            ],
          ),
        ],
      ),
    );

    final sourceCard = _Panel(
      title: 'Sumber rekomendasi',
      subtitle: 'Tempat kamu paling sering menemukan hal menarik',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final s in sources)
            Chip(
              avatar: CircleAvatar(child: Text('${s.value}')),
              label: Text(s.key),
            ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Knowledge Insights')),
      body: RefreshIndicator(
        onRefresh: p.load,
        child: MaxWidth(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              const SectionHeader(title: 'Ringkasan'),
              summary,
              const SizedBox(height: 8),
              if (compact) ...[
                topicCard,
                statusCard,
                mediaCard,
                sourceCard,
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(children: [topicCard, sourceCard]),
                      ),
                      Expanded(
                        child: Column(children: [statusCard, mediaCard]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// Bar horizontal sederhana (tanpa library grafik).
class _Bar extends StatelessWidget {
  const _Bar({
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.icon,
    this.onTap,
  });

  final String label;
  final int value;
  final int max;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
            ],
            SizedBox(
              width: 120,
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: max == 0 ? 0 : value / max,
                  minHeight: 12,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.12),
                ),
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$value',
                textAlign: TextAlign.end,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
