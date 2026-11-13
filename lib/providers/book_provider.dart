import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../services/app_exception.dart';
import '../repositories/book_repository.dart';

// State katalog: hasil pencarian + rekomendasi, masing-masing dengan
// loading / data / error. Tidak berisi widget maupun BuildContext.
class BookProvider extends ChangeNotifier {
  BookProvider(this._repository);

  final BookRepository _repository;

  static const defaultQuery = 'psychology';
  static const recommendationQuery = 'software engineering';

  // --- Pencarian (Katalog) ---
  List<Book> _results = [];
  bool _isLoading = false;
  AppException? _error;
  String _query = '';

  List<Book> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error?.message;
  bool get errorIsNetwork => _error?.isNetwork ?? false;
  String get query => _query;
  bool get hasSearched => _query.isNotEmpty;

  // --- Rekomendasi (Home) ---
  List<Book> _recommended = [];
  bool _isLoadingRecommended = false;
  AppException? _recommendedError;

  List<Book> get recommended => List.unmodifiable(_recommended);
  bool get isLoadingRecommended => _isLoadingRecommended;
  String? get recommendedError => _recommendedError?.message;

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    _query = q;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _results = await _repository.searchBooks(q);
    } catch (e) {
      _results = [];
      _error = AppException.from(e, action: 'mencari buku');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() => search(_query.isEmpty ? defaultQuery : _query);

  Future<void> loadRecommendations() async {
    _isLoadingRecommended = true;
    _recommendedError = null;
    notifyListeners();
    try {
      _recommended = await _repository.searchBooks(recommendationQuery);
    } catch (e) {
      _recommendedError = AppException.from(e, action: 'memuat rekomendasi');
    } finally {
      _isLoadingRecommended = false;
      notifyListeners();
    }
  }

  /// Detail (deskripsi) diambil lewat repository, bukan langsung dari screen.
  Future<Book> getDetail(Book book) => _repository.getBookDetail(book);
}
