import 'dart:math';
import '../data/models/album_model.dart';

enum GenreFilterType {
  affinity('Por afinidade'),
  alphabetical('A–Z'),
  mostListeners('Mais ouvintes'),
  leastListeners('Menos ouvintes'),
  similarTo('Parecidos com…');

  final String label;
  const GenreFilterType(this.label);
}

class RecommendationEngine {
  static final Random _random = Random();

  /// Calcula a similaridade de Jaccard entre dois conjuntos de gêneros: |A ∩ B| / |A ∪ B|
  static double jaccardSimilarity(List<String> genresA, List<String> genresB) {
    if (genresA.isEmpty || genresB.isEmpty) return 0.0;
    final setA = genresA.map((g) => g.toLowerCase()).toSet();
    final setB = genresB.map((g) => g.toLowerCase()).toSet();

    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;

    if (union == 0) return 0.0;
    return intersection / union;
  }

  /// "Atualizar feed": Reordena o catálogo por:
  /// afinidade do artista + exploração aleatória + bônus para gêneros ainda não vistos
  static List<Album> rankFeed({
    required List<Album> allAlbums,
    required Set<String> likedAlbumIds,
    required Map<String, int> artistAffinityMap,
  }) {
    // Gêneros dos álbuns curtidos pelo usuário
    final exploredGenres = <String>{};
    for (final album in allAlbums) {
      if (likedAlbumIds.contains(album.id)) {
        exploredGenres.addAll(album.genres.map((g) => g.toLowerCase()));
      }
    }

    final scored = allAlbums.map((album) {
      final artistAffinity = artistAffinityMap[album.artist.toLowerCase()] ?? 0;

      // Bônus para gênero ainda não explorado
      final hasUnexploredGenre = album.genres.any(
        (g) => !exploredGenres.contains(g.toLowerCase()),
      );
      final unexploredBonus = hasUnexploredGenre ? 2.0 : 0.0;

      // Componente de exploração aleatória (0.0 a 1.5)
      final explorationNoise = _random.nextDouble() * 1.5;

      // Pontuação composta de ranking
      final score = (artistAffinity * 1.8) + unexploredBonus + explorationNoise;

      return MapEntry(album, score);
    }).toList();

    // Ordena decrescente por score
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).toList();
  }

  /// Ordenação padrão da página de gênero:
  /// Álbuns de artistas que o usuário já curtiu primeiro (por afinidade).
  /// Se não houver afinidade com nenhum artista do gênero, ordem alfabética (artista, depois álbum).
  static List<Album> defaultGenreOrder({
    required List<Album> genreAlbums,
    required Map<String, int> artistAffinityMap,
  }) {
    final hasAnyAffinity = genreAlbums.any(
      (a) => (artistAffinityMap[a.artist.toLowerCase()] ?? 0) > 0,
    );

    if (!hasAnyAffinity) {
      return sortAlphabetical(genreAlbums);
    }

    final list = List<Album>.from(genreAlbums);
    list.sort((a, b) {
      final affA = artistAffinityMap[a.artist.toLowerCase()] ?? 0;
      final affB = artistAffinityMap[b.artist.toLowerCase()] ?? 0;

      if (affA != affB) {
        return affB.compareTo(affA); // Maior afinidade primeiro
      }
      // Desempate alfabético
      final artistComp = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      if (artistComp != 0) return artistComp;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return list;
  }

  /// Filtro A–Z: artista, depois álbum
  static List<Album> sortAlphabetical(List<Album> albums) {
    final list = List<Album>.from(albums);
    list.sort((a, b) {
      final artistComp = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      if (artistComp != 0) return artistComp;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return list;
  }

  /// Filtro Mais ouvintes
  static List<Album> sortMostListeners(List<Album> albums) {
    final list = List<Album>.from(albums);
    list.sort((a, b) => b.artistMonthlyListeners.compareTo(a.artistMonthlyListeners));
    return list;
  }

  /// Filtro Menos ouvintes
  static List<Album> sortLeastListeners(List<Album> albums) {
    final list = List<Album>.from(albums);
    list.sort((a, b) => a.artistMonthlyListeners.compareTo(b.artistMonthlyListeners));
    return list;
  }

  /// Filtro "Parecidos com…" (Jaccard similarity de gêneros com artista de referência)
  static List<Album> sortSimilarTo({
    required List<Album> albums,
    required String referenceArtist,
    required List<Album> allCatalogAlbums,
  }) {
    // Coleta todos os gêneros associados ao artista de referência
    final referenceGenres = allCatalogAlbums
        .where((a) => a.artist.toLowerCase() == referenceArtist.toLowerCase())
        .expand((a) => a.genres)
        .toList();

    final list = List<Album>.from(albums);
    list.sort((a, b) {
      final simA = jaccardSimilarity(a.genres, referenceGenres);
      final simB = jaccardSimilarity(b.genres, referenceGenres);

      if (simA != simB) {
        return simB.compareTo(simA); // Maior similaridade primeiro
      }
      return b.artistMonthlyListeners.compareTo(a.artistMonthlyListeners);
    });
    return list;
  }
}

