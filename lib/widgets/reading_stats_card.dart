import 'package:flutter/material.dart';

// Reusable widget: ringkasan statistik bacaan (fitur tambahan).
class ReadingStatsCard extends StatelessWidget {
  const ReadingStatsCard({
    super.key,
    required this.total,
    required this.done,
    required this.pagesRead,
    required this.averageRating,
  });

  final int total;
  final int done;
  final int pagesRead;
  final double? averageRating;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final ratio = total == 0 ? 0.0 : done / total;

    Widget metric(IconData icon, String value, String label) => Expanded(
      child: Column(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(label, style: text.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                metric(Icons.menu_book, '$pagesRead', 'Halaman dibaca'),
                metric(
                  Icons.star_rounded,
                  averageRating == null
                      ? '-'
                      : averageRating!.toStringAsFixed(1),
                  'Rata-rata rating',
                ),
                metric(Icons.emoji_events, '$done/$total', 'Buku selesai'),
              ],
            ),
            const SizedBox(height: 16),
            Text('Target koleksi selesai dibaca', style: text.labelLarge),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(value: ratio, minHeight: 10),
            ),
            const SizedBox(height: 4),
            Text('${(ratio * 100).round()}% dari koleksi sudah selesai'),
          ],
        ),
      ),
    );
  }
}
