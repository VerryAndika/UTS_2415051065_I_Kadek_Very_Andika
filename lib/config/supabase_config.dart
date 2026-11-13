// Konfigurasi Supabase project "bookfinder-uts".
//
// Yang disimpan di sini HANYA publishable key: key ini memang dirancang untuk
// aplikasi client dan dibatasi oleh Row Level Security (RLS).
// service_role / secret key TIDAK boleh ada di aplikasi maupun repository.
class SupabaseConfig {
  SupabaseConfig._();

  static const url = 'https://uzzntuknqcazlcugmkrl.supabase.co';
  static const publishableKey =
      'sb_publishable_S6sSZIOkiKz5cEm8b4g91w_ISodHtit';

  static const savedBooksTable = 'saved_books'; // v1 (BookFinder)
  static const learningItemsTable = 'learning_items'; // v2 (Learning Library)
}
