class Chapter {
  final String id;
  final String? title;
  final String chapter;
  final String? volume;
  final String? translatedLanguage;
  final String mangaId;
  final DateTime? publishAt;
  final int? pages;

  Chapter({
    required this.id,
    this.title,
    required this.chapter,
    this.volume,
    this.translatedLanguage,
    required this.mangaId,
    this.publishAt,
    this.pages,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    String mangaId = '';
    for (var rel in relationships) {
      if (rel['type'] == 'manga') {
        mangaId = rel['id'] as String;
        break;
      }
    }

    DateTime? publishAt;
    if (attributes['publishAt'] != null) {
      try {
        publishAt = DateTime.parse(attributes['publishAt']);
      } catch (e) {
        publishAt = null;
      }
    }

    return Chapter(
      id: json['id'] as String,
      title: attributes['title'],
      chapter: attributes['chapter'] ?? 'N/A',
      volume: attributes['volume'],
      translatedLanguage: attributes['translatedLanguage'],
      mangaId: mangaId,
      publishAt: publishAt,
      pages: attributes['pages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'chapter': chapter,
      'volume': volume,
      'translatedLanguage': translatedLanguage,
      'mangaId': mangaId,
      'publishAt': publishAt?.toIso8601String(),
      'pages': pages,
    };
  }

  String get displayTitle {
    if (title != null && title!.isNotEmpty) {
      return 'Cap. $chapter - $title';
    }
    return 'Capítulo $chapter';
  }
}
