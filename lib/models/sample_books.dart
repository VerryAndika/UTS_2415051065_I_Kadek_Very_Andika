import 'book.dart';

// Data contoh sementara (sebelum REST API terhubung) dan untuk widget test.
const sampleBooks = <Book>[
  Book(
    key: '/works/OL17618370W',
    title: 'Clean Code',
    authors: ['Robert C. Martin'],
    firstPublishYear: 2008,
    coverId: 8065615,
    pageCount: 444,
  ),
  Book(
    key: '/works/OL17930368W',
    title: 'The Pragmatic Programmer',
    authors: ['Andrew Hunt', 'David Thomas'],
    firstPublishYear: 1999,
    pageCount: 321,
  ),
  Book(
    key: '/works/OL17930364W',
    title: 'Atomic Habits',
    authors: ['James Clear'],
    firstPublishYear: 2016,
    pageCount: 320,
  ),
  Book(
    key: '/works/OL5735363W',
    title: 'Laskar Pelangi',
    authors: ['Andrea Hirata'],
    firstPublishYear: 2005,
  ),
];
