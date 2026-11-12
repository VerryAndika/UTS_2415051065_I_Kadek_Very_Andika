import 'package:flutter/material.dart';

// Breakpoint layout:
// compact  : lebar < 600   (HP potret)
// medium   : 600 – 1023    (HP lanskap / tablet)
// expanded : >= 1024       (tablet besar / desktop / web)
enum ScreenSize { compact, medium, expanded }

class Responsive {
  Responsive._();

  static const compactMax = 600.0;
  static const mediumMax = 1024.0;

  static ScreenSize sizeOf(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  static ScreenSize fromWidth(double width) {
    if (width < compactMax) return ScreenSize.compact;
    if (width < mediumMax) return ScreenSize.medium;
    return ScreenSize.expanded;
  }

  static bool isCompact(BuildContext context) =>
      sizeOf(context) == ScreenSize.compact;
}

// Reusable widget: grid yang jumlah kolomnya mengikuti lebar yang tersedia
// (LayoutBuilder), sehingga susunan berubah antara HP dan layar lebar.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minItemWidth = 160,
    this.childAspectRatio = 0.62,
    this.padding = const EdgeInsets.all(12),
    this.shrinkWrap = false,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minItemWidth;
  final double childAspectRatio;
  final EdgeInsets padding;
  final bool shrinkWrap;

  static int columnsFor(double width, double minItemWidth) =>
      (width / minItemWidth).floor().clamp(2, 8);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = columnsFor(
          constraints.maxWidth - padding.horizontal,
          minItemWidth,
        );
        return GridView.builder(
          padding: padding,
          shrinkWrap: shrinkWrap,
          physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: itemCount,
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}

// Membatasi lebar konten di layar sangat lebar agar tetap nyaman dibaca.
class MaxWidth extends StatelessWidget {
  const MaxWidth({super.key, required this.child, this.maxWidth = 1200});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
