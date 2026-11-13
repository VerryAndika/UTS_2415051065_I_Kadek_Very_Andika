import 'package:bookfinder/models/book.dart';
import 'package:bookfinder/models/item_status.dart';
import 'package:bookfinder/models/learning_item.dart';
import 'package:bookfinder/models/media_type.dart';
import 'package:bookfinder/providers/library_provider.dart';
import 'package:bookfinder/repositories/learning_item_repository.dart';
import 'package:bookfinder/services/learning_item_data_source.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearningItem', () {
    test('fromJson / toJson konsisten dengan kolom learning_items', () {
      final item = LearningItem.fromJson({
        'id': 1,
        'title': 'Atomic Habits',
        'media_type': 'book',
        'topic': 'Productivity',
        'source': 'YouTube',
        'characteristics': 'Habit, Nonfiction ,  ',
        'reason': 'Ingin memperbaiki rutinitas belajar',
        'status': 'want',
        'created_at': '2026-11-13T08:00:00Z',
      });
      expect(item.mediaType, MediaType.book);
      expect(item.status, ItemStatus.want);
      expect(item.characteristics, ['Habit', 'Nonfiction']);

      final json = item.toJson();
      expect(json['characteristics'], 'Habit, Nonfiction');
      expect(json['status'], 'want');
      expect(json.containsKey('id'), isFalse);
    });

    test('nilai tidak dikenal -> default aman', () {
      final item = LearningItem.fromJson({'title': 'X', 'media_type': '??'});
      expect(item.mediaType, MediaType.other);
      expect(item.status, ItemStatus.inbox);
      expect(item.topic, 'Umum');
    });

    test('fromBook mengisi media, topik, sumber, dan karakteristik', () {
      const book = Book(
        key: '/works/OL1W',
        title: 'Clean Code',
        authors: ['Robert C. Martin'],
        firstPublishYear: 2008,
        subjects: ['software engineering', 'Computer programming'],
      );
      final item = LearningItem.fromBook(book);
      expect(item.mediaType, MediaType.book);
      expect(item.topic, 'Software engineering');
      expect(item.source, 'Open Library');
      expect(item.characteristics, contains('Terbit 2008'));
      expect(item.externalKey, '/works/OL1W');
    });
  });

  group('LibraryProvider', () {
    late LibraryProvider provider;

    setUp(() async {
      provider = LibraryProvider(
        LearningItemRepository(
          InMemoryLearningItemService([
            const LearningItem(
              title: 'Thinking, Fast and Slow',
              topic: 'Psychology',
              status: ItemStatus.want,
            ),
            const LearningItem(
              title: 'Crash Course Psychology',
              mediaType: MediaType.video,
              topic: 'Psychology',
              source: 'YouTube',
            ),
            const LearningItem(
              title: 'MIT 6.0001',
              mediaType: MediaType.course,
              topic: 'Computer Science',
              status: ItemStatus.done,
            ),
          ]),
        ),
      );
      await provider.load();
    });

    test('ringkasan per media, status, dan topik', () {
      expect(provider.countByMedia(MediaType.book), 1);
      expect(provider.countByStatus(ItemStatus.done), 1);
      expect(provider.topicCounts.first.key, 'Psychology');
      expect(provider.topicCounts.first.value, 2);
      expect(provider.completionRate, closeTo(1 / 3, 0.001));
    });

    test('filter media + topik + pencarian', () {
      provider.setTopicFilter('Psychology');
      expect(provider.visibleItems, hasLength(2));
      provider.setMediaFilter(MediaType.video);
      expect(provider.visibleItems.single.title, 'Crash Course Psychology');
      provider.clearFilters();
      provider.setQuery('mit');
      expect(provider.visibleItems.single.mediaType, MediaType.course);
    });

    test('CRUD: add, setStatus, remove', () async {
      final created = await provider.add(
        const LearningItem(
          title: 'Paper Attention',
          mediaType: MediaType.research,
        ),
      );
      expect(provider.items, hasLength(4));
      await provider.setStatus(created, ItemStatus.progress);
      expect(provider.findById(created.id)!.status, ItemStatus.progress);
      await provider.remove(provider.findById(created.id)!);
      expect(provider.items, hasLength(3));
    });
  });
}
