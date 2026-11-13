import '../models/topic_summary.dart';
import '../services/topic_service.dart';

// Repository ringkasan topik dengan cache sederhana di memori,
// sehingga topik yang sama tidak diminta berulang kali ke API.
class TopicRepository {
  TopicRepository(this._service);

  final TopicService _service;
  final _cache = <String, Future<TopicSummary?>>{};

  Future<TopicSummary?> getSummary(String topic) {
    final key = topic.trim().toLowerCase();
    final cached = _cache[key];
    if (cached != null) return cached;
    final future = _service.getSummary(topic);
    _cache[key] = future;
    // Jangan simpan kegagalan di cache agar bisa dicoba lagi.
    future.catchError((Object _) {
      _cache.remove(key);
      return null;
    });
    return future;
  }

  void forget(String topic) => _cache.remove(topic.trim().toLowerCase());
}
