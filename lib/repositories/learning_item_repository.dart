import '../models/learning_item.dart';
import '../services/learning_item_data_source.dart';

// Repository Learning Library: satu pintu CRUD untuk provider.
class LearningItemRepository {
  LearningItemRepository(this._source);

  final LearningItemDataSource _source;

  Future<List<LearningItem>> getAll() => _source.getAll();
  Future<LearningItem> create(LearningItem item) => _source.create(item);
  Future<LearningItem> update(LearningItem item) => _source.update(item);
  Future<void> delete(int id) => _source.delete(id);
}
