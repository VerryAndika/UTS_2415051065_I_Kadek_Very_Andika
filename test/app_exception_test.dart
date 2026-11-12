import 'dart:async';

import 'package:bookfinder/services/app_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('23505 (UNIQUE) -> pesan data duplikat', () {
    final e = AppException.from(
      const PostgrestException(message: 'duplicate key', code: '23505'),
    );
    expect(e.kind, AppErrorKind.validation);
    expect(e.message, contains('sudah ada di koleksi'));
  });

  test('42501 (RLS) -> permission', () {
    final e = AppException.from(
      const PostgrestException(message: 'denied', code: '42501'),
    );
    expect(e.kind, AppErrorKind.permission);
  });

  test('error jaringan & timeout dikenali sebagai network', () {
    expect(
      AppException.from(http.ClientException('Failed to fetch')).isNetwork,
      isTrue,
    );
    expect(AppException.from(TimeoutException('t')).isNetwork, isTrue);
  });

  test('status HTTP diterjemahkan', () {
    expect(AppException.httpStatus(404).kind, AppErrorKind.notFound);
    expect(AppException.httpStatus(503).message, contains('503'));
  });

  test('FormatException -> format', () {
    expect(
      AppException.from(const FormatException()).kind,
      AppErrorKind.format,
    );
  });
}
