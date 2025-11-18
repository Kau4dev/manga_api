class Manga {
  final String id;
  final String title;
  final String? description;
  final List<String> authors;
  final List<String> artists;
  final List<String> tags;
  final String? coverUrl;
  final String status;
  final int? year;
  final double? rating;

  Manga({
    required this.id,
    required this.title,
    this.description,
    required this.authors,
    required this.artists,
    required this.tags,
    this.coverUrl,
    required this.status,
    this.year,
    this.rating,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final attributes = json['attributes'] as Map<String, dynamic>;
    final relationships = json['relationships'] as List<dynamic>? ?? [];

    final titles = attributes['title'] as Map<String, dynamic>? ?? {};
    String title =
        titles['pt-br'] ??
        titles['pt'] ??
        titles['en'] ??
        titles.values.firstOrNull ??
        'Sem título';

    final descriptions =
        attributes['description'] as Map<String, dynamic>? ?? {};
    String? description =
        descriptions['pt-br'] ??
        descriptions['pt'] ??
        descriptions['en'] ??
        descriptions.values.firstOrNull;

    List<String> authors = [];
    List<String> artists = [];
    for (var rel in relationships) {
      if (rel['type'] == 'author') {
        final name = rel['attributes']?['name'];
        if (name != null) authors.add(name);
      } else if (rel['type'] == 'artist') {
        final name = rel['attributes']?['name'];
        if (name != null) artists.add(name);
      }
    }

    final tagsList = attributes['tags'] as List<dynamic>? ?? [];
    List<String> tags = tagsList
        .map((tag) {
          final tagName =
              tag['attributes']?['name'] as Map<String, dynamic>? ?? {};
          return (tagName['pt-br'] ??
                  tagName['pt'] ??
                  tagName['en'] ??
                  'Desconhecido')
              as String;
        })
        .cast<String>()
        .toList();

    return Manga(
      id: json['id'] as String,
      title: title,
      description: description,
      authors: authors,
      artists: artists,
      tags: tags,
      status: attributes['status'] ?? 'unknown',
      year: attributes['year'],
      rating: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'authors': authors,
      'artists': artists,
      'tags': tags,
      'coverUrl': coverUrl,
      'status': status,
      'year': year,
      'rating': rating,
    };
  }

  Manga copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? authors,
    List<String>? artists,
    List<String>? tags,
    String? coverUrl,
    String? status,
    int? year,
    double? rating,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      authors: authors ?? this.authors,
      artists: artists ?? this.artists,
      tags: tags ?? this.tags,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      year: year ?? this.year,
      rating: rating ?? this.rating,
    );
  }
}
