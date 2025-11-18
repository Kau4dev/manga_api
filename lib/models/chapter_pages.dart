class ChapterPages {
  final String chapterId;
  final String baseUrl;
  final String hash;
  final List<String> data;
  final List<String> dataSaver;

  ChapterPages({
    required this.chapterId,
    required this.baseUrl,
    required this.hash,
    required this.data,
    required this.dataSaver,
  });

  factory ChapterPages.fromJson(Map<String, dynamic> json, String chapterId) {
    final chapter = json['chapter'] as Map<String, dynamic>;

    return ChapterPages(
      chapterId: chapterId,
      baseUrl: json['baseUrl'] as String,
      hash: chapter['hash'] as String,
      data: (chapter['data'] as List<dynamic>).cast<String>(),
      dataSaver: (chapter['dataSaver'] as List<dynamic>).cast<String>(),
    );
  }

  List<String> getPageUrls({bool dataSaver = false}) {
    final quality = dataSaver ? 'data-saver' : 'data';
    final pages = dataSaver ? this.dataSaver : data;

    return pages
        .map((filename) => '$baseUrl/$quality/$hash/$filename')
        .toList();
  }
}