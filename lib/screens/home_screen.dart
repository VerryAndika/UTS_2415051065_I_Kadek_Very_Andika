import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../models/item_status.dart';
import '../models/media_type.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/item_visuals.dart';
import '../widgets/responsive.dart';
import '../widgets/section_header.dart';
import 'capture_screen.dart';
import 'item_profile_screen.dart';
import 'profile_screen.dart';

// Home — "Your Learning Collection": ringkasan koleksi per jenis media,
// antrean belajar, item yang sedang dieksplorasi, dan temuan terbaru.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.onOpenLibrary,
    this.onOpenQueue,
    this.onOpenDiscover,
  });

  final void Function(MediaType? media)? onOpenLibrary;
  final VoidCallback? onOpenQueue;
  final VoidCallback? onOpenDiscover;

  static const _mainMedia = [
    MediaType.book,
    MediaType.article,
    MediaType.video,
    MediaType.course,
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<LibraryProvider>();
    final compact = Responsive.isCompact(context);
    final inProgress = p
        .byStatus(ItemStatus.progress)
        .take(compact ? 2 : 4)
        .toList();
    final recent = p.recent;
    final others = MediaType.values
        .where((m) => !_mainMedia.contains(m) && p.countByMedia(m) > 0)
        .toList();

    void openItem(int id) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => ItemProfileScreen(itemId: id)));

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.local_library_rounded),
            SizedBox(width: 8),
            Text(AppConfig.appName),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ganti tema',
            icon: Icon(
              context.watch<ThemeProvider>().isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: context.read<ThemeProvider>().toggle,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              tooltip: 'Profil',
              icon: const CircleAvatar(radius: 15, child: Text('VA')),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: p.load,
        child: MaxWidth(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              const _Hero(),
              const SectionHeader(title: 'Your Learning Collection'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: GridView.count(
                  crossAxisCount: compact ? 2 : 4,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: compact ? 1.45 : 1.9,
                  children: [
                    for (final m in _mainMedia)
                      _MediaTile(
                        media: m,
                        count: p.countByMedia(m),
                        onTap: () => onOpenLibrary?.call(m),
                      ),
                  ],
                ),
              ),
              if (others.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final m in others)
                        ActionChip(
                          avatar: Icon(m.icon, size: 18, color: mediaColor(m)),
                          label: Text('${m.plural} · ${p.countByMedia(m)}'),
                          onPressed: () => onOpenLibrary?.call(m),
                        ),
                    ],
                  ),
                ),
              SectionHeader(
                title: 'Learning Queue',
                action: 'Buka',
                onAction: onOpenQueue,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        for (final s in ItemStatus.values)
                          Expanded(
                            child: InkWell(
                              onTap: onOpenQueue,
                              child: Column(
                                children: [
                                  Icon(s.icon, color: s.color),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${p.countByStatus(s)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    s.label,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (inProgress.isNotEmpty) ...[
                const SectionHeader(title: 'Sedang dieksplorasi'),
                ItemGrid(
                  items: inProgress,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onTap: (i) => openItem(i.id!),
                ),
              ],
              SectionHeader(
                title: 'Recently collected',
                action: 'Lihat semua',
                onAction: () => onOpenLibrary?.call(null),
              ),
              if (p.isLoading && p.items.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (p.error != null)
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ListTile(
                    leading: const Icon(Icons.cloud_off),
                    title: const Text('Library gagal dimuat'),
                    subtitle: Text(p.error!),
                    trailing: TextButton(
                      onPressed: p.load,
                      child: const Text('Coba lagi'),
                    ),
                  ),
                )
              else if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Belum ada item. Tekan tombol Capture untuk menyimpan '
                    'sesuatu yang ingin kamu pelajari.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                )
              else
                ItemGrid(
                  items: recent,
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  onTap: (i) => openItem(i.id!),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
                child: Card(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.travel_explore),
                    title: const Text('Cari inspirasi buku baru'),
                    subtitle: const Text('Discover dari Open Library'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: onOpenDiscover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.tertiary, 0.7)!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${AppConfig.studentName}',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${AppConfig.studentId} • Kelas ${AppConfig.studentClass}',
                  style: TextStyle(
                    color: scheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppConfig.tagline,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CaptureScreen()),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Capture sesuatu'),
                ),
              ],
            ),
          ),
          Icon(
            Icons.auto_awesome,
            size: 64,
            color: scheme.onPrimary.withValues(alpha: 0.35),
          ),
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.media, required this.count, this.onTap});

  final MediaType media;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = mediaColor(media);
    final text = Theme.of(context).textTheme;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: c.withValues(alpha: 0.15),
                    child: Icon(media.icon, color: c, size: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      media.plural,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '$count',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: c,
                ),
              ),
              Text(
                switch (media) {
                  MediaType.book => 'Buku',
                  MediaType.article => 'Artikel dan jurnal',
                  MediaType.video => 'Video pembelajaran',
                  MediaType.course => 'Kursus online',
                  _ => media.label,
                },
                style: text.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
