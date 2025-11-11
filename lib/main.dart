import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/manga_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/manga_details_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/search_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MangaProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        title: 'Manga_Api',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepOrange,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        ),
        themeMode: ThemeMode.system,
        home: const MainNavigationScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/search':
              return MaterialPageRoute(builder: (_) => const SearchScreen());

            case '/manga-details':
              final mangaId = settings.arguments as String;
              return MaterialPageRoute(
                builder: (_) => MangaDetailsScreen(mangaId: mangaId),
              );
            case '/reader':
              final args = settings.arguments as Map<String, String>;
              return MaterialPageRoute(
                builder: (_) => ReaderScreen(
                  chapterId: args['chapterId']!,
                  chapterTitle: args['chapterTitle']!,
                ),
              );
            default:
              return null;
          }
        },
      ),
    );
  }
}
