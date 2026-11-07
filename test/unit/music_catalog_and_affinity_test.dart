import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:urban_adventure/features/feed/data/repositories/local_storage_repository.dart';
import 'package:urban_adventure/features/feed/data/repositories/mock_music_repository.dart';
import 'package:urban_adventure/features/feed/domain/recommendation_engine.dart';

void main() {
  late Directory tempDir;
  late MockMusicRepository mockRepository;
  late LocalStorageRepository storageRepository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test_');
    mockRepository = MockMusicRepository();
    storageRepository = LocalStorageRepository();
    await storageRepository.init(customPath: tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('MockMusicRepository, Faixas e Durações', () {
    test('Contém exatamente os 22 álbuns especificados', () async {
      final albums = await mockRepository.getAllAlbums();
      expect(albums.length, 22);
    });

    test('Todos os álbuns contêm faixas com títulos, durações e duração total preenchidos', () async {
      final albums = await mockRepository.getAllAlbums();
      for (final album in albums) {
        expect(album.tracks, isNotEmpty, reason: '${album.title} deve ter faixas');
        expect(album.totalDuration, isNotEmpty);
        for (final track in album.tracks) {
          expect(track.title, isNotEmpty);
          expect(track.duration, contains(':'));
        }
      }
    });

    test('Clairo, Mitski, Beach House, Soccer Mommy, Phoebe Bridgers e Pavement contêm o gênero indie', () async {
      final albums = await mockRepository.getAllAlbums();
      const requiredIndieArtists = [
        'Clairo',
        'Mitski',
        'Beach House',
        'Soccer Mommy',
        'Phoebe Bridgers',
        'Pavement',
      ];

      for (final artist in requiredIndieArtists) {
        final artistAlbums = albums.where((a) => a.artist == artist).toList();
        expect(artistAlbums, isNotEmpty);
        for (final album in artistAlbums) {
          expect(album.genres.contains('indie'), isTrue);
        }
      }
    });
  });

  group('Cenário de Teste: Curtir Immunity na página indie', () {
    test('Curtir Immunity faz todos os álbuns da Clairo subirem ao topo do gênero indie', () async {
      final allAlbums = await mockRepository.getAllAlbums();
      final indieAlbums = await mockRepository.getAlbumsByGenre('indie');

      // 1. Sem curtidas, ordem é alfabética por artista (Beach House primeiro)
      final initialMap = storageRepository.getArtistAffinityMap(allAlbums);
      final initialOrder = RecommendationEngine.defaultGenreOrder(
        genreAlbums: indieAlbums,
        artistAffinityMap: initialMap,
      );
      expect(initialOrder.first.artist, 'Beach House');

      // 2. Curte o álbum "Immunity"
      await storageRepository.toggleLike('immunity');
      final updatedMap = storageRepository.getArtistAffinityMap(allAlbums);
      expect(updatedMap['clairo'], 1);

      // 3. Na página indie, todos os 3 álbuns de Clairo devem subir para as primeiras posições
      final sortedAfterLike = RecommendationEngine.defaultGenreOrder(
        genreAlbums: indieAlbums,
        artistAffinityMap: updatedMap,
      );

      // Os 3 primeiros álbuns devem ser de Clairo
      expect(sortedAfterLike[0].artist, 'Clairo');
      expect(sortedAfterLike[1].artist, 'Clairo');
      expect(sortedAfterLike[2].artist, 'Clairo');

      // Os demais artistas sem afinidade vêm depois ordenados alfabeticamente
      expect(sortedAfterLike[3].artist, 'Beach House');
    });
  });
}
