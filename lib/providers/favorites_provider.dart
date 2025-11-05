import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/manga.dart';

class FavoritesProvider extends ChangeNotifier {
  List<Manga> _favorites = [];
  static const String _favoritesKey = 'favorites';

  List<Manga> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString(_favoritesKey);

      if (favoritesJson != null) {
        final List<dynamic> decoded = json.decode(favoritesJson);
        _favorites = decoded.map((item) {
          return Manga(
            id: item['id'],
            title: item['title'],
            description: item['description'],
            authors: List<String>.from(item['authors'] ?? []),
            artists: List<String>.from(item['artists'] ?? []),
            tags: List<String>.from(item['tags'] ?? []),
            coverUrl: item['coverUrl'],
            status: item['status'],
            year: item['year'],
            rating: item['rating'],
          );
        }).toList();
        notifyListeners();
      }
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = json.encode(
        _favorites.map((manga) => manga.toJson()).toList(),
      );
      await prefs.setString(_favoritesKey, favoritesJson);
    } catch (e) {
      print('Erro ao salvar favoritos: $e');
    }
  }

  bool isFavorite(String mangaId) {
    return _favorites.any((manga) => manga.id == mangaId);
  }

  Future<void> addFavorite(Manga manga) async {
    if (!isFavorite(manga.id)) {
      _favorites.add(manga);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String mangaId) async {
    _favorites.removeWhere((manga) => manga.id == mangaId);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(Manga manga) async {
    if (isFavorite(manga.id)) {
      await removeFavorite(manga.id);
    } else {
      await addFavorite(manga);
    }
  }
}