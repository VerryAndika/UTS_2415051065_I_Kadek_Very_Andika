import 'package:flutter/material.dart';

import 'book_cover.dart';

// Reusable widget: kartu buku untuk list/grid katalog.
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.title,
    required this.author,
    this.coverUrl,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String author;
  final String? coverUrl;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: BookCover(url: coverUrl, borderRadius: 0)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          author,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodySmall,
                        ),
                        if (subtitle != null)
                          Text(subtitle!, maxLines: 1, style: text.labelSmall),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
