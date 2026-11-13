import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_config.dart';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'providers/book_provider.dart';
import 'providers/library_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/topic_provider.dart';
import 'repositories/book_repository.dart';
import 'repositories/learning_item_repository.dart';
import 'repositories/topic_repository.dart';
import 'screens/home_shell.dart';
import 'services/book_data_source.dart';
import 'services/learning_item_data_source.dart';
import 'services/open_library_service.dart';
import 'services/supabase_learning_item_service.dart';
import 'services/topic_service.dart';

// Learning Library - Project UTS Pemrograman Mobile
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
  // - Learning Library  : database Supabase (tabel learning_items)
  // - Discover buku     : REST API Open Library
  // - Ringkasan topik   : REST API Wikipedia
  final LearningItemDataSource librarySource = SupabaseLearningItemService();
  final BookDataSource bookSource = OpenLibraryService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              LibraryProvider(LearningItemRepository(librarySource))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              BookProvider(BookRepository(bookSource))
                ..search(BookProvider.defaultQuery),
        ),
        ChangeNotifierProvider(
          create: (_) => TopicProvider(TopicRepository(TopicService())),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const LearningLibraryApp(),
    ),
  );
}

class LearningLibraryApp extends StatelessWidget {
  const LearningLibraryApp({super.key});

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
