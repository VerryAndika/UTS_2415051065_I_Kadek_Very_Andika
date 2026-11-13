import 'package:flutter/foundation.dart';

import '../models/topic_summary.dart';
import '../repositories/topic_repository.dart';

// Akses ringkasan topik (Wikipedia) untuk Item Profile & Insights.
class TopicProvider extends ChangeNotifier {
  TopicProvider(this._repository);

  final TopicRepository _repository;

  Future<TopicSummary?> summaryFor(String topic) =>
      _repository.getSummary(topic);

  Future<TopicSummary?> retry(String topic) {
    _repository.forget(topic);
    return _repository.getSummary(topic);
  }
}
