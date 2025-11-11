import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../models/chapter_pages.dart';
import '../services/mangadex_service.dart';

enum ReadingMode { singlePage, continuousScroll, doublePageSpread }

class ReaderScreen extends StatefulWidget {
  final String chapterId;
  final String chapterTitle;

  const ReaderScreen({
    super.key,
    required this.chapterId,
    required this.chapterTitle,
  });

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final MangaDexService _service = MangaDexService();
  ChapterPages? _chapterPages;
  bool _isLoading = true;
  int _currentPage = 0;
  ReadingMode _readingMode = ReadingMode.singlePage;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadChapterPages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadChapterPages() async {
    try {
      final pages = await _service.getChapterPages(widget.chapterId);
      setState(() {
        _chapterPages = pages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar páginas: $e')));
      }
    }
  }

  void _showReadingModeMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Modo de Leitura',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildModeOption(
              ReadingMode.singlePage,
              'Página Única',
              'Arraste para os lados + zoom',
              Icons.image,
            ),
            _buildModeOption(
              ReadingMode.continuousScroll,
              'Rolagem Contínua',
              'Role para baixo + toque para zoom',
              Icons.view_stream,
            ),
            _buildModeOption(
              ReadingMode.doublePageSpread,
              'Página Dupla',
              'Duas páginas + toque para zoom',
              Icons.book,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(
    ReadingMode mode,
    String title,
    String subtitle,
    IconData icon,
  ) {
    final isSelected = _readingMode == mode;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.orange : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.orange)
          : null,
      onTap: () {
        setState(() => _readingMode = mode);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterTitle),
        actions: [
          if (!_isLoading && _chapterPages != null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showReadingModeMenu,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chapterPages == null
          ? const Center(child: Text('Erro ao carregar páginas'))
          : Column(
              children: [
                if (_readingMode == ReadingMode.singlePage)
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.black87,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Página ${_currentPage + 1} de ${_chapterPages!.getPageUrls().length}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: _buildReader()),
              ],
            ),
    );
  }

  Widget _buildReader() {
    switch (_readingMode) {
      case ReadingMode.singlePage:
        return _buildSinglePageMode();
      case ReadingMode.continuousScroll:
        return _buildContinuousScrollMode();
      case ReadingMode.doublePageSpread:
        return _buildDoublePageMode();
    }
  }

  Widget _buildSinglePageMode() {
    return PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(_chapterPages!.getPageUrls()[index]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        );
      },
      itemCount: _chapterPages!.getPageUrls().length,
      loadingBuilder: (context, event) =>
          const Center(child: CircularProgressIndicator()),
      onPageChanged: (index) {
        setState(() => _currentPage = index);
      },
      pageController: _pageController,
    );
  }

  Widget _buildContinuousScrollMode() {
    return ListView.builder(
      itemCount: _chapterPages!.getPageUrls().length,
      itemBuilder: (context, index) {
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                // Abre a imagem em tela cheia com zoom
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      backgroundColor: Colors.black,
                      appBar: AppBar(
                        backgroundColor: Colors.transparent,
                        title: Text('Página ${index + 1}'),
                      ),
                      body: PhotoView(
                        imageProvider: NetworkImage(
                          _chapterPages!.getPageUrls()[index],
                        ),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 3,
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: Image.network(
                _chapterPages!.getPageUrls()[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 300,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black54,
              child: Text(
                'Página ${index + 1} - Toque para zoom',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDoublePageMode() {
    final pages = _chapterPages!.getPageUrls();
    final pageCount = (pages.length / 2).ceil();

    return PageView.builder(
      controller: _pageController,
      itemCount: pageCount,
      onPageChanged: (index) {
        setState(() => _currentPage = index * 2);
      },
      itemBuilder: (context, index) {
        final leftIndex = index * 2;
        final rightIndex = leftIndex + 1;

        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // Abre a imagem esquerda em tela cheia com zoom
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.transparent,
                          title: Text('Página ${leftIndex + 1}'),
                        ),
                        body: PhotoView(
                          imageProvider: NetworkImage(pages[leftIndex]),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 3,
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Image.network(pages[leftIndex], fit: BoxFit.contain),
              ),
            ),
            if (rightIndex < pages.length)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // Abre a imagem direita em tela cheia com zoom
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(
                            backgroundColor: Colors.transparent,
                            title: Text('Página ${rightIndex + 1}'),
                          ),
                          body: PhotoView(
                            imageProvider: NetworkImage(pages[rightIndex]),
                            minScale: PhotoViewComputedScale.contained,
                            maxScale: PhotoViewComputedScale.covered * 3,
                            backgroundDecoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Image.network(pages[rightIndex], fit: BoxFit.contain),
                ),
              )
            else
              const Expanded(child: SizedBox()),
          ],
        );
      },
    );
  }
}