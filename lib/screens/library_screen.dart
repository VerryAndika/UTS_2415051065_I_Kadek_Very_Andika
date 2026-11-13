import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_status.dart';
import '../models/media_type.dart';
import '../providers/library_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/item_visuals.dart';
import '../widgets/state_views.dart';
import 'capture_screen.dart';
import 'item_profile_screen.dart';

// Learning Library: semua koleksi. Cari, filter (media, topik, status),
// urutkan, pull-to-refresh, dan layout list/grid responsif.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late final _search = TextEditingController(
    text: context.read<LibraryProvider>().query,
  );

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openItem(int id) => Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => ItemProfileScreen(itemId: id)));

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final items = p.visibleItems;

    Widget body;
    if (p.isLoading && p.items.isEmpty) {
      body = const LoadingView(message: 'Memuat library dari database...');
    } else if (p.error != null) {
      body = ErrorView(
        message: p.error!,
        isNetwork: p.errorIsNetwork,
        onRetry: p.load,
      );
    } else if (p.items.isEmpty) {
      body = EmptyView(
        icon: Icons.local_library_outlined,
        title: 'Library masih kosong',
        message:
            'Simpan buku, video, artikel, atau course yang ingin kamu '
            'pelajari agar tidak hilang.',
        action: FilledButton.icon(
          onPressed: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const CaptureScreen())),
          icon: const Icon(Icons.add),
          label: const Text('Capture item pertama'),
        ),
      );
    } else if (items.isEmpty) {
      body = EmptyView(
        icon: Icons.filter_alt_off_outlined,
        title: 'Tidak ada yang cocok',
        message: 'Tidak ada item untuk pencarian/filter ini.',
        action: TextButton(
          onPressed: () {
            _search.clear();
            p.clearFilters();
          },
          child: const Text('Hapus filter'),
        ),
      );
    } else {
      body = ItemGrid(items: items, onTap: (i) => _openItem(i.id!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Library'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: p.isLoading ? null : p.load,
          ),
          PopupMenuButton<LibrarySort>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort),
            initialValue: p.sort,
            onSelected: p.setSort,
            itemBuilder: (_) => [
              for (final s in LibrarySort.values)
                PopupMenuItem(value: s, child: Text(s.label)),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: TextField(
              controller: _search,
              onChanged: p.setQuery,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Cari judul, topik, sumber, alasan...',
                suffixIcon: p.query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus',
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _search.clear();
                          p.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          // Filter jenis media.
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              children: [
                ChoiceChip(
                  label: Text('Semua (${p.items.length})'),
                  selected: p.mediaFilter == null,
                  onSelected: (_) => p.setMediaFilter(null),
                ),
                for (final m in MediaType.values)
                  if (p.countByMedia(m) > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        avatar: Icon(m.icon, size: 18, color: mediaColor(m)),
                        label: Text('${m.label} (${p.countByMedia(m)})'),
                        selected: p.mediaFilter == m,
                        onSelected: (_) => p.setMediaFilter(m),
                      ),
                    ),
              ],
            ),
          ),
          // Filter topik & status.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey('topic-${p.topicFilter}'),
                    initialValue: p.topicFilter,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Topik',
                      prefixIcon: Icon(Icons.category_outlined, size: 20),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua topik'),
                      ),
                      for (final t in p.topicCounts)
                        DropdownMenuItem(
                          value: t.key,
                          child: Text('${t.key} (${t.value})'),
                        ),
                    ],
                    onChanged: p.setTopicFilter,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<ItemStatus?>(
                    key: ValueKey('status-${p.statusFilter}'),
                    initialValue: p.statusFilter,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      isDense: true,
                      labelText: 'Status',
                      prefixIcon: Icon(Icons.flag_outlined, size: 20),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Semua status'),
                      ),
                      for (final s in ItemStatus.values)
                        DropdownMenuItem(value: s, child: Text(s.label)),
                    ],
                    onChanged: p.setStatusFilter,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: RefreshIndicator(onRefresh: p.load, child: body),
          ),
        ],
      ),
    );
  }
}
