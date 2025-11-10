import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manga_provider.dart';
import '../providers/favorites_provider.dart';
import '../models/manga.dart';
import '../models/chapter.dart';

class MangaDetailsScreen extends StatefulWidget {
  final String mangaId;

  const MangaDetailsScreen({super.key, required this.mangaId});

  @override
  State<MangaDetailsScreen> createState() => _MangaDetailsScreenState();
}

class _MangaDetailsScreenState extends State<MangaDetailsScreen> {
  Manga? _manga;
  List<Chapter> _chapters = [];
  bool _isLoading = true;
  bool _isLoadingChapters = true;

  @override
  void initState() {
    super.initState();
    _loadMangaDetails();
  }

  Future<void> _loadMangaDetails() async {
    final provider = context.read<MangaProvider>();

    final manga = await provider.getMangaDetails(widget.mangaId);
    final chapters = await provider.getMangaChapters(widget.mangaId);

    setState(() {
      _manga = manga;
      _chapters = chapters;
      _isLoading = false;
      _isLoadingChapters = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_manga == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Erro ao carregar mangá')),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _manga!.title,
                style: const TextStyle(
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black,
                    ),
                  ],
                ),
              ),
              background: _manga!.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: _manga!.coverUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 100),
                    ),
            ),
            actions: [
              Consumer<FavoritesProvider>(
                builder: (context, favProvider, child) {
                  final isFavorite = favProvider.isFavorite(_manga!.id);
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      favProvider.toggleFavorite(_manga!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite
                                ? 'Removido dos favoritos'
                                : 'Adicionado aos favoritos',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações básicas
                  if (_manga!.year != null || _manga!.status.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          if (_manga!.year != null) ...[
                            const Icon(Icons.calendar_today, size: 16),
                            const SizedBox(width: 4),
                            Text('${_manga!.year}'),
                            const SizedBox(width: 16),
                          ],
                          if (_manga!.status.isNotEmpty) ...[
                            const Icon(Icons.info_outline, size: 16),
                            const SizedBox(width: 4),
                            Text(_manga!.status),
                          ],
                        ],
                      ),
                    ),

                  // Autores e Artistas
                  if (_manga!.authors.isNotEmpty || _manga!.artists.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_manga!.authors.isNotEmpty) ...[
                            const Text(
                              'Autor(es):',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(_manga!.authors.join(', ')),
                            const SizedBox(height: 8),
                          ],
                          if (_manga!.artists.isNotEmpty) ...[
                            const Text(
                              'Artista(s):',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(_manga!.artists.join(', ')),
                          ],
                        ],
                      ),
                    ),

                  // Descrição
                  if (_manga!.description != null &&
                      _manga!.description!.isNotEmpty) ...[
                    const Text(
                      'Sinopse',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_manga!.description!),
                    const SizedBox(height: 16),
                  ],

                  // Tags
                  if (_manga!.tags.isNotEmpty) ...[
                    const Text(
                      'Tags',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _manga!.tags.take(10).map((tag) {
                        return Chip(
                          label: Text(tag),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Capítulos
                  const Text(
                    'Capítulos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          _isLoadingChapters
              ? const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : _chapters.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Nenhum capítulo disponível'),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final chapter = _chapters[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(child: Text(chapter.chapter)),
                        title: Text(chapter.displayTitle),
                        subtitle: chapter.publishAt != null
                            ? Text(
                                '${chapter.publishAt!.day}/${chapter.publishAt!.month}/${chapter.publishAt!.year}',
                              )
                            : null,
                        trailing: Text(
                          chapter.translatedLanguage?.toUpperCase() ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                          final available = await context
                              .read<MangaProvider>()
                              .isChapterAvailable(chapter.id);
                          if (!mounted) return;
                          navigator.pop();
                          if (!available) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Capítulo indisponível'),
                              ),
                            );
                            return;
                          }

                          Navigator.pushNamed(
                            context,
                            '/reader',
                            arguments: {
                              'chapterId': chapter.id,
                              'chapterTitle': chapter.displayTitle,
                            },
                          );
                        },
                      ),
                    );
                  }, childCount: _chapters.length),
                ),
        ],
      ),
    );
  }
}
