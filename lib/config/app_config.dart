// Konfigurasi global aplikasi Learning Library.
class AppConfig {
  AppConfig._();

  static const appName = 'Learning Library';
  static const tagline = 'Simpan rasa ingin tahumu sebelum hilang.';

  // Identitas mahasiswa (ditampilkan di Home & Profil).
  static const studentName = 'I Kadek Very Andika';
  static const studentId = '2415051065';
  static const studentClass = '5 IKI';

  // REST API publik (tanpa API key).
  static const openLibraryBaseUrl = 'https://openlibrary.org';
  static const coverBaseUrl = 'https://covers.openlibrary.org';
}
