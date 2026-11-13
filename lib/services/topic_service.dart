import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/topic_summary.dart';
import 'app_exception.dart';

// REST API Wikipedia (tanpa API key):
//   GET https://{lang}.wikipedia.org/api/rest_v1/page/summary/{judul}
// Dipakai untuk menjelaskan topik pengetahuan sebuah Learning Item.
class TopicService {
  TopicService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const timeout = Duration(seconds: 12);

  /// Ringkasan topik; null jika halaman tidak ditemukan (404).
  /// Mencoba Wikipedia bahasa Indonesia dulu, lalu bahasa Inggris.
  Future<TopicSummary?> getSummary(String topic) async {
    for (final lang in const ['id', 'en']) {
      final uri = Uri.https(
        '$lang.wikipedia.org',
        '/api/rest_v1/page/summary/${topic.trim().replaceAll(' ', '_')}',
      );
      try {
        final res = await _client.get(uri).timeout(timeout);
        if (res.statusCode == 404) continue;
        if (res.statusCode != 200) {
          throw AppException.httpStatus(res.statusCode, action: 'memuat topik');
        }
        final json = jsonDecode(res.body);
        if (json is! Map<String, dynamic>) throw const FormatException();
        final summary = TopicSummary.fromJson(json);
        if (summary.extract.isEmpty || json['type'] == 'disambiguation') {
          continue;
        }
        return summary;
      } catch (e) {
        throw AppException.from(e, action: 'memuat ringkasan topik');
      }
    }
    return null;
  }
}
