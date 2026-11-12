import 'package:flutter/material.dart';

// Koleksi Saya: daftar buku yang disimpan (akan terhubung ke database).
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Koleksi Saya')),
      body: const Center(child: Text('Belum ada buku di koleksi.')),
    );
  }
}
