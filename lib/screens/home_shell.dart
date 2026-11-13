import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/media_type.dart';
import '../providers/library_provider.dart';
import '../widgets/responsive.dart';
import 'capture_screen.dart';
import 'discover_screen.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'library_screen.dart';
import 'queue_screen.dart';

// Navigasi utama: NavigationBar (compact) / NavigationRail (medium &
// expanded) + tombol Capture yang selalu tersedia.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Indeks tab adalah state lokal UI, cukup setState.
  int _index = 0;

  static const _destinations = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.local_library_outlined, Icons.local_library, 'Library'),
    (Icons.view_kanban_outlined, Icons.view_kanban, 'Queue'),
    (Icons.travel_explore_outlined, Icons.travel_explore, 'Discover'),
    (Icons.insights_outlined, Icons.insights, 'Insights'),
  ];

  void _select(int i) => setState(() => _index = i);

  void _openLibrary({MediaType? media, String? topic}) {
    final p = context.read<LibraryProvider>();
    p.clearFilters();
    if (media != null) p.setMediaFilter(media);
    if (topic != null) p.setTopicFilter(topic);
    _select(1);
  }

  void _capture() =>
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const CaptureScreen()));

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onOpenLibrary: (m) => _openLibrary(media: m),
        onOpenQueue: () => _select(2),
        onOpenDiscover: () => _select(3),
      ),
      const LibraryScreen(),
      const QueueScreen(),
      const DiscoverScreen(),
      InsightsScreen(onOpenTopic: (t) => _openLibrary(topic: t)),
    ];
    final body = IndexedStack(index: _index, children: pages);
    final showFab = _index <= 2;

    if (Responsive.isCompact(context)) {
      return Scaffold(
        body: body,
        floatingActionButton: showFab
            ? FloatingActionButton.extended(
                onPressed: _capture,
                icon: const Icon(Icons.add),
                label: const Text('Capture'),
              )
            : null,
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
              child: expanded
                  ? FloatingActionButton.extended(
                      heroTag: 'rail-capture',
                      onPressed: _capture,
                      icon: const Icon(Icons.add),
                      label: const Text('Capture'),
                    )
                  : FloatingActionButton(
                      heroTag: 'rail-capture',
                      tooltip: 'Capture',
                      onPressed: _capture,
                      child: const Icon(Icons.add),
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
