import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../config/supabase_config.dart';
import '../providers/library_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/responsive.dart';

// Profile/About: identitas mahasiswa, pengaturan tema, info aplikasi.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final theme = context.watch<ThemeProvider>();
    final library = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: MaxWidth(
        maxWidth: 720,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Center(
              child: CircleAvatar(
                radius: 44,
                child: Text(
                  'VA',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              AppConfig.studentName,
              textAlign: TextAlign.center,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Text(
              'NIM ${AppConfig.studentId}',
              textAlign: TextAlign.center,
            ),
            const Text(
              'Kelas ${AppConfig.studentClass}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${library.items.length} item • ${library.topicCounts.length} topik',
              textAlign: TextAlign.center,
              style: text.bodySmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                secondary: Icon(
                  theme.isDark ? Icons.dark_mode : Icons.light_mode,
                ),
                title: const Text('Mode gelap'),
                subtitle: const Text('Ganti tema terang / gelap'),
                value: theme.isDark,
                onChanged: theme.setDark,
              ),
            ),
            const Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.local_library_outlined),
                    title: Text(AppConfig.appName),
                    subtitle: Text(
                      '${AppConfig.tagline}\nProject UTS Pemrograman Mobile — v2.0.0',
                    ),
                    isThreeLine: true,
                  ),
                  ListTile(
                    leading: Icon(Icons.public),
                    title: Text('REST API'),
                    subtitle: Text(
                      'Open Library (Discover buku) • Wikipedia (ringkasan topik)',
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.storage),
                    title: Text('Database'),
                    subtitle: Text(
                      'Supabase (PostgreSQL) — tabel '
                      '${SupabaseConfig.learningItemsTable}',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
