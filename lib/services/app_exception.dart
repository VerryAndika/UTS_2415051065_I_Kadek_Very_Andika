import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

// Jenis error untuk menentukan ikon/pesan di UI.
enum AppErrorKind {
  network,
  server,
  notFound,
  validation,
  permission,
  format,
  unknown,
}

// Exception aplikasi dengan pesan yang ramah pengguna.
class AppException implements Exception {
  const AppException(
    this.message, {
    this.kind = AppErrorKind.unknown,
    this.code,
  });

  final String message;
  final AppErrorKind kind;
  final String? code;

  bool get isNetwork => kind == AppErrorKind.network;

  @override
  String toString() => message;

  /// Menerjemahkan error teknis (network, HTTP, PostgreSQL/PostgREST, JSON)
  /// menjadi AppException. [action] mis. "memuat buku", "menyimpan data".
  static AppException from(Object error, {String action = 'memproses data'}) {
    if (error is AppException) return error;

    if (error is TimeoutException) {
      return AppException(
        'Gagal $action: server terlalu lama merespons. Coba lagi.',
        kind: AppErrorKind.network,
      );
    }

    if (error is PostgrestException) {
      final code = error.code;
      final (message, kind) = switch (code) {
        '23505' => (
          'Buku ini sudah ada di koleksi (data duplikat).',
          AppErrorKind.validation,
        ),
        '23514' => (
          'Data ditolak database: nilai tidak memenuhi aturan '
              '(rating 1–5, halaman tidak melebihi total).',
          AppErrorKind.validation,
        ),
        '23502' => ('Data wajib belum diisi.', AppErrorKind.validation),
        '42501' => (
          'Akses ditolak oleh Row Level Security database.',
          AppErrorKind.permission,
        ),
        'PGRST116' => ('Data tidak ditemukan.', AppErrorKind.notFound),
        _ => ('Gagal $action: ${error.message}', AppErrorKind.server),
      };
      return AppException(message, kind: kind, code: code);
    }

    if (error is FormatException) {
      return AppException(
        'Gagal $action: format data dari server tidak sesuai.',
        kind: AppErrorKind.format,
      );
    }

    // dart:io tidak tersedia di web, jadi deteksi error jaringan lewat teks.
    final text = error.toString();
    if (error is http.ClientException ||
        text.contains('SocketException') ||
        text.contains('Failed to fetch') ||
        text.contains('Failed host lookup') ||
        text.contains('Connection refused') ||
        text.contains('AuthRetryableFetchException')) {
      return AppException(
        'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.',
        kind: AppErrorKind.network,
      );
    }

    if (error is StateError) {
      return AppException(error.message, kind: AppErrorKind.notFound);
    }

    return AppException('Gagal $action: $text');
  }

  /// Pesan untuk status HTTP selain 2xx dari REST API.
  static AppException httpStatus(
    int statusCode, {
    String action = 'memuat data',
  }) {
    final (message, kind) = switch (statusCode) {
      404 => ('Data tidak ditemukan (HTTP 404).', AppErrorKind.notFound),
      429 => (
        'Terlalu banyak permintaan ke server (HTTP 429). Tunggu sebentar.',
        AppErrorKind.server,
      ),
      >= 500 => (
        'Server sedang bermasalah (HTTP $statusCode). Coba lagi nanti.',
        AppErrorKind.server,
      ),
      _ => ('Gagal $action (HTTP $statusCode).', AppErrorKind.server),
    };
    return AppException(message, kind: kind, code: '$statusCode');
  }
}
