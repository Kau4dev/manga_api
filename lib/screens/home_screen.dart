import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/manga_provider.dart';
import '../models/manga.dart';
import '../models/chapter.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega dados ao iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<MangaProvider>();
      provider.loadPopularManga();
      provider.loadRecentChapters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MangaDex'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Abre a tela de busca como tela completa
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<MangaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingPopular && provider.popularManga.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadPopularManga();
              await provider.loadRecentChapters();
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seção de Mangás Populares
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Mangás Populares',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: 280,
                    child: provider.popularManga.isEmpty
                        ? const Center(child: Text('Nenhum mangá encontrado'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: provider.popularManga.length,
                            itemBuilder: (context, index) {
                              return _buildMangaCard(
                                context,
                                provider.popularManga[index],
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Seção de Capítulos Recentes
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Capítulos Recentes',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  provider.isLoadingRecent && provider.recentChapters.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : provider.recentChapters.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Nenhum capítulo encontrado'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: provider.recentChapters.length,
                          itemBuilder: (context, index) {
                            return _buildChapterCard(
                              context,
                              provider.recentChapters[index],
                            );
                          },
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMangaCard(BuildContext context, Manga manga) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/manga-details', arguments: manga.id);
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: manga.coverUrl != null
                  ? CachedNetworkImage(
                      imageUrl: manga.coverUrl!,
                      height: 220,
                      width: 150,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 220,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    )
                  : Container(
                      height: 220,
                      color: Colors.grey[300],
                      child: const Icon(Icons.book, size: 50),
                    ),
            ),
            const SizedBox(height: 8),
            Text(
              manga.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterCard(BuildContext context, Chapter chapter) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.menu_book),
        title: Text(
          chapter.displayTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Manga ID: ${chapter.mangaId}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          chapter.translatedLanguage?.toUpperCase() ?? '',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        onTap: () async {
          // Verifica disponibilidade antes de navegar
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );
          final available = await context
              .read<MangaProvider>()
              .isChapterAvailable(chapter.id);
          final navigator = Navigator.of(context);
          if (!mounted) return;
          navigator.pop();
          if (!available) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Capítulo indisponível')),
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
  }
}
