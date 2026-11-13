import 'package:flutter/material.dart';

import '../models/item_status.dart';
import '../models/learning_item.dart';
import '../models/media_type.dart';

// Warna khas tiap jenis media (dipakai thumbnail, badge, dan grafik).
Color mediaColor(MediaType m) => switch (m) {
  MediaType.book => const Color(0xFF0F766E),
  MediaType.article => const Color(0xFF7C3AED),
  MediaType.video => const Color(0xFFDC2626),
  MediaType.course => const Color(0xFF2563EB),
  MediaType.game => const Color(0xFFEA580C),
  MediaType.podcast => const Color(0xFFDB2777),
  MediaType.research => const Color(0xFF0891B2),
  MediaType.other => const Color(0xFF64748B),
};

// Reusable widget: thumbnail item. Pakai cover jika ada, jika tidak
// tampilkan gradien sesuai jenis media + ikon.
class ItemThumb extends StatelessWidget {
  const ItemThumb({
    super.key,
    required this.item,
    this.width,
    this.height,
    this.radius = 12,
  });

  final LearningItem item;
  final double? width;
  final double? height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = mediaColor(item.mediaType);
    final fallback = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, Color.lerp(color, Colors.black, 0.35)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        item.mediaType.icon,
        color: Colors.white.withValues(alpha: 0.9),
        size: (height ?? 80) * 0.32,
      ),
    );
    final url = item.coverUrl;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: url == null || url.isEmpty
          ? fallback
          : Image.network(
              url,
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (c, child, p) => p == null ? child : fallback,
              errorBuilder: (c, e, s) => fallback,
            ),
    );
  }
}

// Reusable widget: badge kecil berwarna (media / status / topik).
class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    this.icon,
    this.color,
    this.dense = false,
  });

  factory Pill.media(MediaType m, {bool dense = false}) =>
      Pill(label: m.label, icon: m.icon, color: mediaColor(m), dense: dense);

  factory Pill.status(ItemStatus s, {bool dense = false}) =>
      Pill(label: s.label, icon: s.icon, color: s.color, dense: dense);

  final String label;
  final IconData? icon;
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 10,
        vertical: dense ? 2 : 5,
      ),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 12 : 15, color: c),
            SizedBox(width: dense ? 3 : 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: c,
                fontWeight: FontWeight.w600,
                fontSize: dense ? 10.5 : 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
