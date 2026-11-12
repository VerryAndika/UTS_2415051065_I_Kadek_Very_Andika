import 'package:flutter/material.dart';

// BookFinder - Project UTS Pemrograman Mobile
// 2415051065 - I Kadek Very Andika (5 IKI)
void main() {
  runApp(const BookFinderApp());
}

class BookFinderApp extends StatelessWidget {
  const BookFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const Scaffold(
        body: Center(
          child: Text('BookFinder\n2415051065 - I Kadek Very Andika',
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
