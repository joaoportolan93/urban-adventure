import '../models/album_model.dart';

abstract class MusicCatalogRepository {
  /// Retorna todo o catálogo de álbuns
  Future<List<Album>> getAllAlbums();

  /// Busca um álbum pelo ID único
  Future<Album?> getAlbumById(String id);

  /// Filtra álbuns que contenham o gênero especificado (case-insensitive)
  Future<List<Album>> getAlbumsByGenre(String genre);

  /// Retorna a lista distinta de todos os gêneros disponíveis no catálogo
  Future<List<String>> getAllGenres();

  /// Busca álbuns por correspondência em título, artista ou gênero
  Future<List<Album>> search(String query);
}

