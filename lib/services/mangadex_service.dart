import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';
import '../models/chapter.dart';
import '../models/chapter_pages.dart';

class MangaDexService {
  static const String baseUrl = 'https://api.mangadex.org';
  static const String coverBaseUrl = 'https://uploads.mangadex.org/covers';

  Future<List<Manga>> getPopularManga({int limit = 20, int offset = 0}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/manga?limit=$limit&offset=$offset&order[followedCount]=desc&includes[]=cover_art&includes[]=author&includes[]=artist&contentRating[]=safe&contentRating[]=suggestive',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mangaList = (data['data'] as List)
            .map((manga) => _parseMangaWithCover(manga))
            .toList();
        return mangaList;
      } else {
        throw Exception('Falha ao carregar mangás populares');
      }
    } catch (e) {
      print('Erro ao buscar mangás populares: $e');
      return [];
    }
  }

  Future<List<Manga>> searchManga(String query, {int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/manga?title=$query&limit=$limit&includes[]=cover_art&includes[]=author&includes[]=artist&contentRating[]=safe&contentRating[]=suggestive',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final mangaList = (data['data'] as List)
            .map((manga) => _parseMangaWithCover(manga))
            .toList();
        return mangaList;
      } else {
        throw Exception('Falha ao buscar mangás');
      }
    } catch (e) {
      print('Erro ao buscar mangás: $e');
      return [];
    }
  }

  // Obtém detalhes de um mangá
  Future<Manga?> getMangaDetails(String mangaId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/manga/$mangaId?includes[]=cover_art&includes[]=author&includes[]=artist',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseMangaWithCover(data['data']);
      } else {
        throw Exception('Falha ao carregar detalhes do mangá');
      }
    } catch (e) {
      print('Erro ao buscar detalhes do mangá: $e');
      return null;
    }
  }

  Future<List<Chapter>> getMangaChapters(
    String mangaId, {
    int limit = 100,
    int offset = 0,
    String translatedLanguage = 'pt-br',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/manga/$mangaId/feed?limit=$limit&offset=$offset&translatedLanguage[]=$translatedLanguage&order[chapter]=desc&includes[]=manga',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chapters = (data['data'] as List)
            .map((chapter) => Chapter.fromJson(chapter))
            .toList();
        return chapters;
      } else {
        throw Exception('Falha ao carregar capítulos');
      }
    } catch (e) {
      print('Erro ao buscar capítulos: $e');
      return [];
    }
  }

  Future<List<Chapter>> getRecentChapters({
    int limit = 20,
    String translatedLanguage = 'pt-br',
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/chapter?limit=$limit&translatedLanguage[]=$translatedLanguage&order[publishAt]=desc&includes[]=manga&contentRating[]=safe&contentRating[]=suggestive',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final chapters = (data['data'] as List)
            .map((chapter) => Chapter.fromJson(chapter))
            .toList();
        return chapters;
      } else {
        throw Exception('Falha ao carregar capítulos recentes');
      }
    } catch (e) {
      print('Erro ao buscar capítulos recentes: $e');
      return [];
    }
  }

  Future<ChapterPages?> getChapterPages(String chapterId) async {
    try {
      print('Buscando páginas para o capítulo: $chapterId');
      final response = await http.get(
        Uri.parse('$baseUrl/at-home/server/$chapterId'),
      );

      print('Status da resposta: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Dados recebidos: ${data.keys}');
        return ChapterPages.fromJson(data, chapterId);
      } else {
        print('Erro na API: ${response.statusCode} - ${response.body}');
        throw Exception('Falha ao carregar páginas do capítulo');
      }
    } catch (e) {
      print('Erro ao buscar páginas do capítulo: $e');
      return null;
    }
  }

  Manga _parseMangaWithCover(Map<String, dynamic> mangaData) {
    Manga manga = Manga.fromJson(mangaData);

    final relationships = mangaData['relationships'] as List<dynamic>? ?? [];
    for (var rel in relationships) {
      if (rel['type'] == 'cover_art') {
        final fileName = rel['attributes']?['fileName'];
        if (fileName != null) {
          final coverUrl = '$coverBaseUrl/${manga.id}/$fileName.512.jpg';
          manga = manga.copyWith(coverUrl: coverUrl);
        }
        break;
      }
    }

    return manga;
  }

  Future<String> getMangaTitle(String mangaId) async {
    try {
      final manga = await getMangaDetails(mangaId);
      return manga?.title ?? 'Desconhecido';
    } catch (e) {
      print('Erro ao buscar título do mangá: $e');
      return 'Desconhecido';
    }
  }
}
