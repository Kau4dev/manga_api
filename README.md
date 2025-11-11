# MangaDex Reader App

Um aplicativo Flutter completo para ler mangás usando a API do MangaDex.

## 🎯 Funcionalidades

- **📚 Catálogo de Mangás**: Navegue por mangás populares
- **🔍 Busca Avançada**: Pesquise mangás por título
- **⭐ Favoritos**: Salve seus mangás favoritos localmente
- **📖 Leitura de Capítulos**: Interface de leitura completa com:
  - Navegação entre páginas
  - Zoom nas imagens
  - Modo fullscreen
  - Controles intuitivos
- **📱 Design Responsivo**: Tema claro e escuro automático
- **🌐 API MangaDex**: Integração completa com a API do MangaDex

## 🏗️ Estrutura do Projeto

```
lib/
├── models/              # Modelos de dados
│   ├── manga.dart
│   ├── chapter.dart
│   └── chapter_pages.dart
├── providers/           # Gerenciamento de estado
│   ├── manga_provider.dart
│   └── favorites_provider.dart
├── services/            # Serviços de API
│   └── mangadex_service.dart
├── screens/             # Telas do app
│   ├── main_navigation_screen.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── favorites_screen.dart
│   ├── manga_details_screen.dart
│   └── reader_screen.dart
└── main.dart           # Ponto de entrada
```

## 📦 Dependências

- **provider**: Gerenciamento de estado
- **http**: Requisições HTTP
- **cached_network_image**: Cache de imagens
- **shared_preferences**: Armazenamento local
- **photo_view**: Visualizador de imagens com zoom

## 🚀 Como Executar

1. Certifique-se de ter o Flutter instalado
2. Clone o repositório
3. Execute os comandos:

```bash
flutter pub get
flutter run
```

## 📱 Telas

### Home Screen

- Exibe mangás populares em um carrossel horizontal
- Mostra capítulos recentes
- Navegação rápida para busca

### Search Screen

- Campo de busca para encontrar mangás
- Exibição em grade dos resultados
- Navegação para detalhes do mangá

### Favorites Screen

- Lista de mangás favoritos salvos localmente
- Remover favoritos com um toque
- Sincronização automática

### Manga Details Screen

- Capa do mangá em destaque
- Informações completas (autor, artista, sinopse, tags)
- Lista de capítulos disponíveis
- Botão para adicionar/remover dos favoritos

### Reader Screen

- Visualização de páginas em modo fullscreen
- Navegação por gestos
- Zoom nas imagens
- Controles de navegação
- Indicador de progresso

## 🌐 API MangaDex

O app utiliza a API oficial do MangaDex:

- Base URL: `https://api.mangadex.org`
- Documentação: `https://api.mangadex.org/docs/`

### Endpoints Utilizados:

- `GET /manga` - Lista mangás populares
- `GET /manga/{id}` - Detalhes do mangá
- `GET /manga/{id}/feed` - Capítulos do mangá
- `GET /chapter` - Capítulos recentes
- `GET /at-home/server/{chapterId}` - URLs das páginas

## 🎨 Características Técnicas

- **Arquitetura**: Provider (State Management)
- **Pattern**: Repository Pattern
- **UI/UX**: Material Design 3
- **Cache**: Imagens em cache para melhor performance
- **Persistência**: SharedPreferences para favoritos
- **Navegação**: Named routes com passagem de argumentos

## 📄 Licença

Este projeto é de código aberto e está disponível sob a licença MIT.

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou pull requests.

## 📧 Contato

Para dúvidas ou sugestões, abra uma issue no repositório.

---

Desenvolvido com ❤️ usando Flutter e MangaDex API
