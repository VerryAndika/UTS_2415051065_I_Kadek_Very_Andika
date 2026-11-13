import '../models/learning_item.dart';

// Kontrak sumber data Learning Library (CRUD).
abstract class LearningItemDataSource {
  Future<List<LearningItem>> getAll();
  Future<LearningItem> create(LearningItem item);
  Future<LearningItem> update(LearningItem item);
  Future<void> delete(int id);
}

// Implementasi di memori: untuk test & mode tanpa database.
class InMemoryLearningItemService implements LearningItemDataSource {
  InMemoryLearningItemService([List<LearningItem> seed = const []]) {
    for (final item in seed) {
      _rows.add(_withId(item));
    }
  }

  final _rows = <LearningItem>[];
  int _nextId = 1;

  LearningItem _withId(LearningItem item) => LearningItem.fromJson({
    ...item.toJson(),
    'id': _nextId++,
    'created_at': (item.createdAt ?? DateTime.now()).toIso8601String(),
  });

  @override
  Future<List<LearningItem>> getAll() async => List.unmodifiable(_rows);

  @override
  Future<LearningItem> create(LearningItem item) async {
    final row = _withId(item);
    _rows.insert(0, row);
    return row;
  }

  @override
  Future<LearningItem> update(LearningItem item) async {
    final i = _rows.indexWhere((r) => r.id == item.id);
    if (i < 0) throw StateError('Item tidak ditemukan.');
    _rows[i] = item;
    return item;
  }

  @override
  Future<void> delete(int id) async => _rows.removeWhere((r) => r.id == id);
}
