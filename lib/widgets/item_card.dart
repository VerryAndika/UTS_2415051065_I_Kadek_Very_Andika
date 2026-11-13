import 'package:flutter/material.dart';

import '../models/learning_item.dart';
import 'item_visuals.dart';

// Reusable widget: kartu Learning Item untuk list (horizontal) atau grid.
class ItemCard extends StatelessWidget {
  const ItemCard({super.key, required this.item, this.onTap, this.trailing});

  final LearningItem item;
  final VoidCallback? onTap;
  final Widget? trailing;

  static const double height = 136;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final reason = item.reason ?? item.description ?? '';
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ItemThumb(item: item, width: 74, height: 112, radius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${item.mediaType.label} · ${item.topic}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: mediaColor(item.mediaType),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(child: Pill.status(item.status, dense: true)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'via ${item.source}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// Grid/list responsif untuk ItemCard (1 kolom di HP, 2–3 di layar lebar).
class ItemGrid extends StatelessWidget {
  const ItemGrid({
    super.key,
    required this.items,
    required this.onTap,
    this.shrinkWrap = false,
    this.padding = const EdgeInsets.fromLTRB(12, 4, 12, 88),
  });

  final List<LearningItem> items;
  final void Function(LearningItem) onTap;
  final bool shrinkWrap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final columns = c.maxWidth >= 1100
            ? 3
            : c.maxWidth >= 640
            ? 2
            : 1;
        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: ItemCard.height,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: items.length,
          itemBuilder: (context, i) =>
              ItemCard(item: items[i], onTap: () => onTap(items[i])),
        );
      },
    );
  }
}
