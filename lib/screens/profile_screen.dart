import 'package:flutter/material.dart';

import '../config/app_config.dart';

// Profile/About: identitas mahasiswa dan informasi aplikasi.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 44,
              child: Icon(Icons.person, size: 44),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppConfig.studentName,
            textAlign: TextAlign.center,
            style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Text(AppConfig.studentId, textAlign: TextAlign.center),
          const Text(
            'Kelas ${AppConfig.studentClass}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text(AppConfig.appName),
              subtitle: Text('Project UTS Pemrograman Mobile'),
            ),
          ),
        ],
      ),
    );
  }
}
