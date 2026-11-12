import 'package:bookfinder/models/reading_status.dart';
import 'package:bookfinder/models/saved_book.dart';
import 'package:bookfinder/widgets/saved_book_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const initial = SavedBook(
    bookKey: '/works/OL1W',
    title: 'Buku Uji',
    author: 'Penulis',
    totalPages: 100,
  );

  Future<List<SavedBook>> pumpForm(WidgetTester tester) async {
    final submitted = <SavedBook>[];
    await tester.binding.setSurfaceSize(const Size(500, 1200));
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SavedBookForm(
            initial: initial,
            submitLabel: 'Simpan',
            onSubmit: (b) async => submitted.add(b),
          ),
        ),
      ),
    );
    return submitted;
  }

  testWidgets('halaman melebihi total -> pesan validasi, tidak tersimpan', (
    tester,
  ) async {
    final submitted = await pumpForm(tester);
    await tester.enterText(find.byKey(const Key('field_current_page')), '150');
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(
      find.text('Tidak boleh melebihi jumlah halaman (100)'),
      findsOneWidget,
    );
    expect(submitted, isEmpty);
  });

  testWidgets('status Selesai tanpa rating -> wajib beri rating', (
    tester,
  ) async {
    final submitted = await pumpForm(tester);
    await tester.tap(find.text('Selesai'));
    await tester.pump();
    await tester.tap(find.text('Simpan'));
    await tester.pump();

    expect(
      find.text('Beri rating untuk buku yang sudah selesai dibaca'),
      findsOneWidget,
    );
    expect(submitted, isEmpty);
  });

  testWidgets('data valid -> onSubmit dipanggil dengan nilai form', (
    tester,
  ) async {
    final submitted = await pumpForm(tester);
    await tester.tap(find.text('Sedang dibaca'));
    await tester.enterText(find.byKey(const Key('field_current_page')), '40');
    await tester.enterText(find.byKey(const Key('field_note')), 'Seru sekali');
    await tester.tap(find.byTooltip('4 bintang'));
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();

    expect(submitted, hasLength(1));
    expect(submitted.first.status, ReadingStatus.reading);
    expect(submitted.first.currentPage, 40);
    expect(submitted.first.rating, 4);
    expect(submitted.first.note, 'Seru sekali');
  });
}
