import 'package:flutter/material.dart';

// Reusable widget: cover buku dari URL dengan placeholder & fallback.
class BookCover extends StatelessWidget {
  const BookCover({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  final String? url;
  final double? width;
  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Container(
      width: width,
      height: height,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(Icons.menu_book_rounded, color: scheme.outline, size: 36),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: url == null || url!.isEmpty
          ? placeholder
          : Image.network(
              url!,
              width: width,
              height: height,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : placeholder,
              errorBuilder: (context, error, stack) => placeholder,
            ),
    );
  }
}
