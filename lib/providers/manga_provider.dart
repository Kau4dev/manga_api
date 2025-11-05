import 'package:flutter/foundation.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import '../services/mangadex_service.dart';

class MangaProvider extends ChangeNotifier {
  final MangaDexService _service = MangaDexService();

  List<Manga> _popularManga = [];
  List<Chapter> _recentChapters = [];
  List<Manga> _searchResults = [];

  bool _isLoadingPopular = false;
  bool _isLoadingRecent = false;
  bool _isSearching = false;

  String? _error;

  List<Manga> get popularManga => _popularManga;
  List<Chapter> get recentChapters => _recentChapters;
  List<Manga> get searchResults => _searchResults;

  bool get isLoadingPopular => _isLoadingPopular;
  bool get isLoadingRecent => _isLoadingRecent;
  bool get isSearching => _isSearching;

  String? get error => _error;

  Future<void> loadPopularManga({int limit = 20, int offset = 0}) async {
    _isLoadingPopular = true;
    _error = null;
    notifyListeners();

    try {
      _popularManga = await _service.getPopularManga(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      _error = 'Erro ao carregar mangás populares: $e';
      print(_error);
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  Future<void> loadRecentChapters({int limit = 20}) async {
    _isLoadingRecent = true;
    _error = null;
    notifyListeners();

    try {
      _recentChapters = await _service.getRecentChapters(limit: limit);
    } catch (e) {
      _error = 'Erro ao carregar capítulos recentes: $e';
      print(_error);
    } finally {
      _isLoadingRecent = false;
      notifyListeners();
    }
  }

  Future<void> searchManga(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _error = null;
    notifyListeners();

    try {
      _searchResults = await _service.searchManga(query);
    } catch (e) {
      _error = 'Erro ao buscar mangás: $e';
      print(_error);
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }

  Future<Manga?> getMangaDetails(String mangaId) async {
    try {
      return await _service.getMangaDetails(mangaId);
    } catch (e) {
      print('Erro ao obter detalhes do mangá: $e');
      return null;
    }
  }

  // Obtém capítulos de um mangá
  Future<List<Chapter>> getMangaChapters(String mangaId) async {
    try {
      return await _service.getMangaChapters(mangaId);
    } catch (e) {
      print('Erro ao obter capítulos: $e');
      return [];
    }
  }

  // Tenta buscar as páginas de um capítulo e retorna null se indisponível
  Future<bool> isChapterAvailable(String chapterId) async {
    try {
      final pages = await _service.getChapterPages(chapterId);
      return pages != null;
    } catch (e) {
      print('Erro ao verificar disponibilidade do capítulo: $e');
      return false;
    }
  }
}
