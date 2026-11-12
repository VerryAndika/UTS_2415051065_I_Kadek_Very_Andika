import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../repositories/book_repository.dart';

// State katalog: hasil pencarian + rekomendasi, masing-masing dengan
// loading / data / error. Tidak berisi widget maupun BuildContext.
class BookProvider extends ChangeNotifier {
  BookProvider(this._repository);

  final BookRepository _repository;

  static const defaultQuery = 'programming';
  static const recommendationQuery = 'software engineering';

  // --- Pencarian (Katalog) ---
  List<Book> _results = [];
  bool _isLoading = false;
  String? _error;
  String _query = '';

  List<Book> get results => List.unmodifiable(_results);
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get query => _query;
  bool get hasSearched => _query.isNotEmpty;

  // --- Rekomendasi (Home) ---
  List<Book> _recommended = [];
  bool _isLoadingRecommended = false;
  String? _recommendedError;

  List<Book> get recommended => List.unmodifiable(_recommended);
  bool get isLoadingRecommended => _isLoadingRecommended;
  String? get recommendedError => _recommendedError;

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
      _error = e.toString();
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
      _recommendedError = e.toString();
    } finally {
      _isLoadingRecommended = false;
      notifyListeners();
    }
  }

  /// Detail (deskripsi) diambil lewat repository, bukan langsung dari screen.
  Future<Book> getDetail(Book book) => _repository.getBookDetail(book);
}
