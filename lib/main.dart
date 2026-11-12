import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'providers/book_provider.dart';
import 'providers/collection_provider.dart';
import 'repositories/book_repository.dart';
import 'repositories/saved_book_repository.dart';
import 'screens/home_shell.dart';
import 'services/book_data_source.dart';
import 'services/open_library_service.dart';
import 'services/saved_book_data_source.dart';

// BookFinder - Project UTS Pemrograman Mobile
// 2415051065 - I Kadek Very Andika (5 IKI)
//
// Arsitektur: UI (screens/widgets) -> providers -> repositories
//             -> services (REST API / database) -> models
void main() {
  // Sumber data dipilih di satu tempat ini saja.
  final BookDataSource bookSource = OpenLibraryService();
  final SavedBookDataSource savedSource = InMemorySavedBookService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookProvider(BookRepository(bookSource))
            ..loadRecommendations()
            ..search(BookProvider.defaultQuery),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              CollectionProvider(SavedBookRepository(savedSource))..load(),
        ),
      ],
      child: const BookFinderApp(),
    ),
  );
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
      home: const HomeShell(),
    );
  }
}
