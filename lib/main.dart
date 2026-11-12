import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/book_provider.dart';
import 'providers/collection_provider.dart';
import 'providers/theme_provider.dart';
import 'repositories/book_repository.dart';
import 'repositories/saved_book_repository.dart';
import 'screens/home_shell.dart';
import 'services/book_data_source.dart';
import 'services/open_library_service.dart';
import 'services/saved_book_data_source.dart';
import 'services/supabase_saved_book_service.dart';

// BookFinder - Project UTS Pemrograman Mobile
// 2415051065 - I Kadek Very Andika (5 IKI)
//
// Arsitektur: UI (screens/widgets) -> providers -> repositories
//             -> services (REST API / database) -> models
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  // Sumber data dipilih di satu tempat ini saja:
  // katalog dari REST API, koleksi pribadi dari database Supabase.
  final BookDataSource bookSource = OpenLibraryService();
  final SavedBookDataSource savedSource = SupabaseSavedBookService();

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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
      themeMode: context.watch<ThemeProvider>().mode,
      home: const HomeShell(),
    );
  }
}
