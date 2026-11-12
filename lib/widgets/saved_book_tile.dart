import 'package:flutter/material.dart';

import '../models/saved_book.dart';
import 'book_cover.dart';
import 'rating_input.dart';

// Reusable widget: satu item koleksi (cover, status, rating, progress).
class SavedBookTile extends StatelessWidget {
  const SavedBookTile({super.key, required this.book, this.onTap, this.onEdit});

  final SavedBook book;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  /// Tinggi tetap saat dipakai di grid (mainAxisExtent).
  static const double height = 132;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final progress = book.progress;

    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCover(
                url: book.coverUrl,
                width: 56,
                height: 84,
                borderRadius: 8,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(book.status.icon, size: 16, color: scheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            book.status.label,
                            style: text.labelMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        RatingStars(rating: book.rating, size: 14),
                      ],
                    ),
                    if (progress != null) ...[
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${book.currentPage}/${book.totalPages} hal • '
                        '${(progress * 100).round()}%',
                        style: text.labelSmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: onEdit,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
