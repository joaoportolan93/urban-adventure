import 'package:flutter_test/flutter_test.dart';
import 'package:urban_adventure/features/feed/data/models/album_model.dart';
import 'package:urban_adventure/features/feed/domain/recommendation_engine.dart';

void main() {
  const album1 = Album(
    id: 'a1',
    title: 'Kind of Blue',
    artist: 'Miles Davis',
    genres: ['jazz', 'modal jazz'],
    artistMonthlyListeners: 4200000,
  );

  const album2 = Album(
    id: 'a2',
    title: 'Bitches Brew',
    artist: 'Miles Davis',
    genres: ['jazz', 'jazz fusion'],
    artistMonthlyListeners: 4200000,
  );

  const album3 = Album(
    id: 'a3',
    title: 'Blue Train',
    artist: 'John Coltrane',
    genres: ['jazz', 'hard bop'],
    artistMonthlyListeners: 3100000,
  );

  const album4 = Album(
    id: 'a4',
    title: 'Currents',
    artist: 'Tame Impala',
    genres: ['psychedelic pop', 'synth-pop'],
    artistMonthlyListeners: 28000000,
  );

  final testAlbums = [album1, album2, album3, album4];

  group('RecommendationEngine - Jaccard Similarity', () {
    test('Calcula corretamente interseção sobre união', () {
      // ['jazz', 'modal jazz'] e ['jazz', 'jazz fusion'] => interseção 1 ('jazz'), união 3
      final sim = RecommendationEngine.jaccardSimilarity(
        ['jazz', 'modal jazz'],
        ['jazz', 'jazz fusion'],
      );
      expect(sim, closeTo(1 / 3, 0.001));

      // Conjuntos disjuntos
      final zeroSim = RecommendationEngine.jaccardSimilarity(
        ['jazz'],
        ['rock'],
      );
      expect(zeroSim, 0.0);
    });
  });

  group('RecommendationEngine - Filtros de Gênero', () {
    test('defaultGenreOrder sem afinidade ordena A-Z (artista, depois álbum)', () {
      final sorted = RecommendationEngine.defaultGenreOrder(
        genreAlbums: [album3, album1], // John Coltrane vs Miles Davis
        artistAffinityMap: {}, // Zero afinidade
      );

      expect(sorted[0].artist, 'John Coltrane');
      expect(sorted[1].artist, 'Miles Davis');
    });

    test('defaultGenreOrder com afinidade prioriza artista com curtidas', () {
      final sorted = RecommendationEngine.defaultGenreOrder(
        genreAlbums: [album3, album1],
        artistAffinityMap: {'miles davis': 2, 'john coltrane': 0},
      );

      expect(sorted[0].artist, 'Miles Davis');
      expect(sorted[1].artist, 'John Coltrane');
    });

    test('sortMostListeners e sortLeastListeners ordenam por ouvintes', () {
      final most = RecommendationEngine.sortMostListeners(testAlbums);
      expect(most.first.title, 'Currents'); // 28M
      expect(most.last.title, 'Blue Train'); // 3.1M

      final least = RecommendationEngine.sortLeastListeners(testAlbums);
      expect(least.first.title, 'Blue Train');
      expect(least.last.title, 'Currents');
    });

    test('sortSimilarTo ranqueia álbuns mais parecidos com o artista de referência', () {
      final similar = RecommendationEngine.sortSimilarTo(
        albums: [album4, album3], // Currents (pop) vs Blue Train (jazz)
        referenceArtist: 'Miles Davis', // gêneros: jazz, modal jazz, jazz fusion
        allCatalogAlbums: testAlbums,
      );

      // Blue Train divide 'jazz' com Miles Davis, portanto tem maior similaridade que Currents
      expect(similar.first.title, 'Blue Train');
    });
  });
}

