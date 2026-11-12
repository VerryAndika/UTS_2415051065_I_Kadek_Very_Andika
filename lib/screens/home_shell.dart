import 'package:flutter/material.dart';

import '../widgets/responsive.dart';
import 'catalog_screen.dart';
import 'collection_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';

// Navigasi utama: NavigationBar (compact) / NavigationRail (medium & expanded).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Indeks tab adalah state lokal UI, cukup setState.
  int _index = 0;

  static const _destinations = [
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.search_outlined, Icons.search, 'Katalog'),
    (
      Icons.collections_bookmark_outlined,
      Icons.collections_bookmark,
      'Koleksi',
    ),
    (Icons.person_outline, Icons.person, 'Profil'),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onOpenCatalog: () => _select(1)),
      const CatalogScreen(),
      CollectionScreen(onOpenCatalog: () => _select(1)),
      const ProfileScreen(),
    ];
    final body = IndexedStack(index: _index, children: pages);

    if (Responsive.isCompact(context)) {
      return Scaffold(
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            for (final (icon, selected, label) in _destinations)
              NavigationDestination(
                icon: Icon(icon),
                selectedIcon: Icon(selected),
                label: label,
              ),
          ],
        ),
      );
    }

    final expanded = Responsive.sizeOf(context) == ScreenSize.expanded;
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _index,
            onDestinationSelected: _select,
            extended: expanded,
            labelType: expanded
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.all,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Icon(
                Icons.auto_stories,
                color: Theme.of(context).colorScheme.primary,
                size: 32,
              ),
            ),
            destinations: [
              for (final (icon, selected, label) in _destinations)
                NavigationRailDestination(
                  icon: Icon(icon),
                  selectedIcon: Icon(selected),
                  label: Text(label),
                ),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
