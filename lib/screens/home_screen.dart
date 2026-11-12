import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../widgets/book_card.dart';
import '../widgets/section_header.dart';
import '../widgets/stat_card.dart';

// Home/Dashboard: sapaan, pencarian cepat, ringkasan koleksi, rekomendasi.
// (Data masih dummy; akan diganti REST API & database pada tahap berikutnya.)
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _dummyBooks = [
    {'title': 'Clean Code', 'author': 'Robert C. Martin'},
    {'title': 'The Pragmatic Programmer', 'author': 'Andrew Hunt'},
    {'title': 'Atomic Habits', 'author': 'James Clear'},
    {'title': 'Laskar Pelangi', 'author': 'Andrea Hirata'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConfig.appName)),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${AppConfig.studentName}',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Text(
                  '${AppConfig.studentId} • ${AppConfig.studentClass}',
                ),
                const SizedBox(height: 12),
                const TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Cari judul atau penulis...',
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Koleksi Saya'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Ingin dibaca',
                    value: '0',
                    icon: Icons.bookmark_add,
                  ),
                ),
                Expanded(
                  child: StatCard(
                    label: 'Selesai',
                    value: '0',
                    icon: Icons.task_alt,
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader(title: 'Rekomendasi'),
          SizedBox(
            height: 250,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _dummyBooks.length,
              separatorBuilder: (_, _) => const SizedBox(width: 4),
              itemBuilder: (context, i) => SizedBox(
                width: 150,
                child: BookCard(
                  title: _dummyBooks[i]['title']!,
                  author: _dummyBooks[i]['author']!,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
