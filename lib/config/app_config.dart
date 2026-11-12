// Konfigurasi global aplikasi BookFinder.
class AppConfig {
  AppConfig._();

  static const appName = 'BookFinder';

  // Identitas mahasiswa (ditampilkan di Profile & header).
  static const studentName = 'I Kadek Very Andika';
  static const studentId = '2415051065';
  static const studentClass = '5 IKI';

  // REST API publik Open Library (tanpa API key).
  static const openLibraryBaseUrl = 'https://openlibrary.org';
  static const coverBaseUrl = 'https://covers.openlibrary.org';
}
