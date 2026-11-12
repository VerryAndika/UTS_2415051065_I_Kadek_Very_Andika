import 'book.dart';

// Data contoh (key & cover asli Open Library) untuk SampleBookService
// dan widget test, sehingga aplikasi bisa diuji tanpa jaringan.
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
    key: '/works/OL5748544W',
    title: 'The Pragmatic Programmer',
    authors: ['Andy Hunt', 'Dave Thomas'],
    firstPublishYear: 1999,
    coverId: 10143650,
    pageCount: 352,
  ),
  Book(
    key: '/works/OL17930368W',
    title: 'Atomic Habits',
    authors: ['James Clear'],
    firstPublishYear: 2016,
    coverId: 12539702,
    pageCount: 322,
  ),
  Book(
    key: '/works/OL15302003W',
    title: 'Laskar Pelangi',
    authors: ['Andrea Hirata'],
    firstPublishYear: 2005,
    coverId: 7079796,
    pageCount: 534,
  ),
];
