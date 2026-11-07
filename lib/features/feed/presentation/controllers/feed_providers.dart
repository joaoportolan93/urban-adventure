import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/album_model.dart';
import '../../data/models/folder_model.dart';
import '../../data/repositories/local_storage_repository.dart';
import '../../data/repositories/mock_music_repository.dart';
import '../../data/repositories/music_repository.dart';
import '../../domain/recommendation_engine.dart';

// Repositórios
final localStorageProvider = Provider<LocalStorageRepository>((ref) {
  throw UnimplementedError('localStorageProvider deve ser inicializado no main');
});

final musicRepositoryProvider = Provider<MusicCatalogRepository>((ref) {
  return MockMusicRepository();
});

// Catálogo completo assíncrono
final catalogAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  final repo = ref.watch(musicRepositoryProvider);
  return repo.getAllAlbums();
});

// Lista reativa de IDs favoritados (♥)
class LikedAlbumsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final storage = ref.watch(localStorageProvider);
    return storage.getLikedAlbumIds();
  }

  Future<void> toggleLike(String albumId) async {
    final storage = ref.read(localStorageProvider);
    await storage.toggleLike(albumId);
    state = storage.getLikedAlbumIds();
  }
}

final likedAlbumsProvider =
    NotifierProvider<LikedAlbumsNotifier, Set<String>>(LikedAlbumsNotifier.new);

// Lista reativa de Pastas
class FoldersNotifier extends Notifier<List<Folder>> {
  @override
  List<Folder> build() {
    final storage = ref.watch(localStorageProvider);
    return storage.getFolders();
  }

  Future<void> createFolder(String name) async {
    final storage = ref.read(localStorageProvider);
    await storage.createFolder(name);
    state = storage.getFolders();
  }

  Future<void> toggleAlbumInFolder(String folderId, String albumId) async {
    final storage = ref.read(localStorageProvider);
    await storage.toggleAlbumInFolder(folderId, albumId);
    state = storage.getFolders();
  }
}

final foldersProvider =
    NotifierProvider<FoldersNotifier, List<Folder>>(FoldersNotifier.new);

// Estado do Feed reordenado
class FeedAlbumsNotifier extends AsyncNotifier<List<Album>> {
  @override
  Future<List<Album>> build() async {
    final repo = ref.watch(musicRepositoryProvider);
    final storage = ref.watch(localStorageProvider);
    final allAlbums = await repo.getAllAlbums();
    final likedIds = ref.watch(likedAlbumsProvider);
    final affinityMap = storage.getArtistAffinityMap(allAlbums);

    return RecommendationEngine.rankFeed(
      allAlbums: allAlbums,
      likedAlbumIds: likedIds,
      artistAffinityMap: affinityMap,
    );
  }

  /// "Atualizar feed": Força recálculo por gosto + exploração aleatória + gêneros novos
  Future<void> refreshFeed() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(musicRepositoryProvider);
      final storage = ref.read(localStorageProvider);
      final allAlbums = await repo.getAllAlbums();
      final likedIds = ref.read(likedAlbumsProvider);
      final affinityMap = storage.getArtistAffinityMap(allAlbums);

      return RecommendationEngine.rankFeed(
        allAlbums: allAlbums,
        likedAlbumIds: likedIds,
        artistAffinityMap: affinityMap,
      );
    });
  }
}

final feedAlbumsProvider =
    AsyncNotifierProvider<FeedAlbumsNotifier, List<Album>>(FeedAlbumsNotifier.new);

// Busca ativa com Notifier idiomático para Riverpod 3.x
class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

// Filtro do Feed com busca combinada
final searchFilteredAlbumsProvider = Provider<AsyncValue<List<Album>>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  final feedAsync = ref.watch(feedAlbumsProvider);

  if (query.isEmpty) {
    return feedAsync;
  }

  return feedAsync.whenData((albums) {
    return albums.where((album) {
      final titleMatch = album.title.toLowerCase().contains(query);
      final artistMatch = album.artist.toLowerCase().contains(query);
      final genreMatch = album.genres.any((g) => g.toLowerCase().contains(query));
      return titleMatch || artistMatch || genreMatch;
    }).toList();
  });
});
