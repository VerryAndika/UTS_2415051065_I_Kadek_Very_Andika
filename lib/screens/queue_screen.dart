import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item_status.dart';
import '../models/learning_item.dart';
import '../providers/library_provider.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/item_card.dart';
import '../widgets/responsive.dart';
import '../widgets/state_views.dart';
import 'item_profile_screen.dart';

// Learning Queue: rencana eksplorasi per status. HP: tab per status;
// layar lebar: papan 4 kolom (kanban). Item bisa dipindah status
// lewat menu, atau dihapus dengan geser + konfirmasi.
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final wide = Responsive.sizeOf(context) == ScreenSize.expanded;

    Widget content;
    if (p.isLoading && p.items.isEmpty) {
      content = const LoadingView();
    } else if (p.error != null) {
      content = ErrorView(
        message: p.error!,
        isNetwork: p.errorIsNetwork,
        onRetry: p.load,
      );
    } else if (wide) {
      content = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final s in ItemStatus.values)
            Expanded(
              child: _Column(status: s, items: p.byStatus(s)),
            ),
        ],
      );
    } else {
      content = TabBarView(
        children: [
          for (final s in ItemStatus.values)
            _QueueList(status: s, items: p.byStatus(s)),
        ],
      );
    }

    return DefaultTabController(
      length: ItemStatus.values.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Learning Queue'),
          bottom: wide
              ? null
              : TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    for (final s in ItemStatus.values)
                      Tab(
                        icon: Icon(s.icon, color: s.color),
                        text: '${s.label} (${p.countByStatus(s)})',
                      ),
                  ],
                ),
        ),
        body: content,
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({required this.status, required this.items});

  final ItemStatus status;
  final List<LearningItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(status.icon, color: status.color),
            title: Text(
              '${status.label} (${items.length})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(status.hint),
          ),
          Expanded(
            child: _QueueList(status: status, items: items),
          ),
        ],
      ),
    );
  }
}

class _QueueList extends StatelessWidget {
  const _QueueList({required this.status, required this.items});

  final ItemStatus status;
  final List<LearningItem> items;

  Future<bool> _confirmDelete(BuildContext context, LearningItem item) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Hapus dari Library?',
      message: '"${item.title}" akan dihapus permanen dari database.',
    );
    if (!ok || !context.mounted) return false;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<LibraryProvider>().remove(item);
      messenger.showSnackBar(
        SnackBar(content: Text('"${item.title}" dihapus')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
    return false; // item hilang karena list provider berubah
  }

  Future<void> _move(
    BuildContext context,
    LearningItem item,
    ItemStatus to,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await context.read<LibraryProvider>().setStatus(item, to);
      messenger.showSnackBar(
        SnackBar(
          content: Text('"${item.title}" → ${to.label}'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Gagal: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyView(
        icon: status.icon,
        title: 'Belum ada item ${status.label}',
        message: status.hint,
      );
    }
    return RefreshIndicator(
      onRefresh: context.read<LibraryProvider>().load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 88),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          return SizedBox(
            height: ItemCard.height,
            child: Dismissible(
              key: ValueKey('q-${item.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                color: Theme.of(context).colorScheme.errorContainer,
                child: const Icon(Icons.delete_outline),
              ),
              confirmDismiss: (_) => _confirmDelete(context, item),
              child: ItemCard(
                item: item,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ItemProfileScreen(itemId: item.id!),
                  ),
                ),
                trailing: PopupMenuButton<ItemStatus>(
                  tooltip: 'Pindahkan',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (to) => _move(context, item, to),
                  itemBuilder: (_) => [
                    for (final s in ItemStatus.values)
                      if (s != item.status)
                        PopupMenuItem(
                          value: s,
                          child: Row(
                            children: [
                              Icon(s.icon, color: s.color, size: 20),
                              const SizedBox(width: 8),
                              Text('Pindah ke ${s.label}'),
                            ],
                          ),
                        ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
