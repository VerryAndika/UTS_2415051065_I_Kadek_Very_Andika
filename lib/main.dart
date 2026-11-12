import 'package:flutter/material.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';

// BookFinder - Project UTS Pemrograman Mobile
// 2415051065 - I Kadek Very Andika (5 IKI)
//
// Arsitektur: UI (screens/widgets) -> providers -> repositories
//             -> services (REST API / database) -> models
void main() {
  runApp(const BookFinderApp());
}

class BookFinderApp extends StatelessWidget {
  const BookFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const Scaffold(
        body: Center(
          child: Text(
            '${AppConfig.appName}\n${AppConfig.studentId} - ${AppConfig.studentName}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
