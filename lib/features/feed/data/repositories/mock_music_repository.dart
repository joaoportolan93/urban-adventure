import '../models/album_model.dart';
import 'music_repository.dart';

class MockMusicRepository implements MusicCatalogRepository {
  // 22 álbuns com faixas, durações individuais, duração total do álbum e gêneros amplos
  static const List<Album> _mockAlbums = [
    Album(
      id: 'kind-of-blue',
      title: 'Kind of Blue',
      artist: 'Miles Davis',
      genres: ['jazz', 'experimental'],
      artistMonthlyListeners: 4200000, // FICTÍCIO: Miles Davis
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '45 min 44 s',
      tracks: [
        Track(number: 1, title: 'So What', duration: '9:22'),
        Track(number: 2, title: 'Freddie Freeloader', duration: '9:46'),
        Track(number: 3, title: 'Blue in Green', duration: '5:37'),
        Track(number: 4, title: 'All Blues', duration: '11:33'),
        Track(number: 5, title: 'Flamenco Sketches', duration: '9:26'),
      ],
    ),
    Album(
      id: 'ok-computer',
      title: 'OK Computer',
      artist: 'Radiohead',
      genres: ['rock', 'eletrônica'],
      artistMonthlyListeners: 18500000, // FICTÍCIO: Radiohead
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '53 min 21 s',
      tracks: [
        Track(number: 1, title: 'Airbag', duration: '4:44'),
        Track(number: 2, title: 'Paranoid Android', duration: '6:23'),
        Track(number: 3, title: 'Subterranean Homesick Alien', duration: '4:27'),
        Track(number: 4, title: 'Exit Music (For a Film)', duration: '4:24'),
        Track(number: 5, title: 'Let Down', duration: '4:59'),
        Track(number: 6, title: 'Karma Police', duration: '4:21'),
        Track(number: 7, title: 'No Surprises', duration: '3:48'),
      ],
    ),
    Album(
      id: 'loveless',
      title: 'Loveless',
      artist: 'My Bloody Valentine',
      genres: ['shoegaze', 'dream-pop'],
      artistMonthlyListeners: 2100000, // FICTÍCIO: My Bloody Valentine
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '48 min 36 s',
      tracks: [
        Track(number: 1, title: 'Only Shallow', duration: '4:17'),
        Track(number: 2, title: 'Loomer', duration: '2:38'),
        Track(number: 3, title: 'To Here Knows When', duration: '5:31'),
        Track(number: 4, title: 'When You Sleep', duration: '4:11'),
        Track(number: 5, title: 'Sometimes', duration: '5:19'),
        Track(number: 6, title: 'Soon', duration: '6:58'),
      ],
    ),
    Album(
      id: 'to-pimp-a-butterfly',
      title: 'To Pimp a Butterfly',
      artist: 'Kendrick Lamar',
      genres: ['hiphop', 'jazz'],
      artistMonthlyListeners: 68000000, // FICTÍCIO: Kendrick Lamar
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '78 min 51 s',
      tracks: [
        Track(number: 1, title: "Wesley's Theory", duration: '4:47'),
        Track(number: 2, title: 'King Kunta', duration: '3:54'),
        Track(number: 3, title: 'Institutionalized', duration: '4:31'),
        Track(number: 4, title: 'These Walls', duration: '5:00'),
        Track(number: 5, title: 'Alright', duration: '3:39'),
        Track(number: 6, title: 'The Blacker the Berry', duration: '5:28'),
      ],
    ),
    Album(
      id: 'blonde',
      title: 'Blonde',
      artist: 'Frank Ocean',
      genres: ['r&b', 'bedroom-pop'],
      artistMonthlyListeners: 34000000, // FICTÍCIO: Frank Ocean
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '60 min 08 s',
      tracks: [
        Track(number: 1, title: 'Nikes', duration: '5:14'),
        Track(number: 2, title: 'Ivy', duration: '4:09'),
        Track(number: 3, title: 'Pink + White', duration: '3:04'),
        Track(number: 4, title: 'Solo', duration: '4:17'),
        Track(number: 5, title: 'Nights', duration: '5:07'),
        Track(number: 6, title: 'White Ferrari', duration: '4:08'),
      ],
    ),
    Album(
      id: 'madvillainy',
      title: 'Madvillainy',
      artist: 'Madvillain',
      genres: ['hiphop', 'experimental'],
      artistMonthlyListeners: 5200000, // FICTÍCIO: Madvillain
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '46 min 22 s',
      tracks: [
        Track(number: 1, title: 'Accordion', duration: '1:58'),
        Track(number: 2, title: 'Meat Grinder', duration: '2:11'),
        Track(number: 3, title: 'Bistro', duration: '1:07'),
        Track(number: 4, title: 'Raid', duration: '2:30'),
        Track(number: 5, title: "America's Most Blunted", duration: '3:54'),
        Track(number: 6, title: 'All Caps', duration: '2:10'),
      ],
    ),
    Album(
      id: 'currents',
      title: 'Currents',
      artist: 'Tame Impala',
      genres: ['rock', 'pop'],
      artistMonthlyListeners: 28000000, // FICTÍCIO: Tame Impala
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '51 min 06 s',
      tracks: [
        Track(number: 1, title: 'Let It Happen', duration: '7:46'),
        Track(number: 2, title: 'Nangs', duration: '1:47'),
        Track(number: 3, title: 'The Moment', duration: '4:15'),
        Track(number: 4, title: "Yes I'm Changing", duration: '4:30'),
        Track(number: 5, title: 'Eventually', duration: '5:19'),
        Track(number: 6, title: 'The Less I Know the Better', duration: '3:36'),
      ],
    ),
    Album(
      id: 'titanic-rising',
      title: 'Titanic Rising',
      artist: 'Weyes Blood',
      genres: ['pop', 'folk'],
      artistMonthlyListeners: 1800000, // FICTÍCIO: Weyes Blood
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '42 min 22 s',
      tracks: [
        Track(number: 1, title: "A Lot's Gonna Change", duration: '4:21'),
        Track(number: 2, title: 'Andromeda', duration: '4:40'),
        Track(number: 3, title: 'Everyday', duration: '5:07'),
        Track(number: 4, title: 'Something to Believe', duration: '4:45'),
        Track(number: 5, title: 'Movies', duration: '5:53'),
        Track(number: 6, title: 'Wild Time', duration: '6:09'),
      ],
    ),
    Album(
      id: 'punisher',
      title: 'Punisher',
      artist: 'Phoebe Bridgers',
      genres: ['indie', 'folk'],
      artistMonthlyListeners: 9500000, // FICTÍCIO: Phoebe Bridgers
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '40 min 38 s',
      tracks: [
        Track(number: 1, title: 'DVD Menu', duration: '1:09'),
        Track(number: 2, title: 'Garden Song', duration: '3:59'),
        Track(number: 3, title: 'Kyoto', duration: '3:04'),
        Track(number: 4, title: 'Punisher', duration: '3:09'),
        Track(number: 5, title: 'Halloween', duration: '4:31'),
        Track(number: 6, title: 'Chinese Satellite', duration: '3:37'),
        Track(number: 7, title: 'Moon Song', duration: '4:37'),
        Track(number: 8, title: 'I Know the End', duration: '5:44'),
      ],
    ),
    Album(
      id: 'in-rainbows',
      title: 'In Rainbows',
      artist: 'Radiohead',
      genres: ['rock', 'eletrônica'],
      artistMonthlyListeners: 18500000, // FICTÍCIO: Radiohead
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '42 min 39 s',
      tracks: [
        Track(number: 1, title: '15 Step', duration: '3:57'),
        Track(number: 2, title: 'Bodysnatchers', duration: '4:02'),
        Track(number: 3, title: 'Nude', duration: '4:15'),
        Track(number: 4, title: 'Weird Fishes/Arpeggi', duration: '5:18'),
        Track(number: 5, title: 'All I Need', duration: '3:48'),
        Track(number: 6, title: 'Reckoner', duration: '4:50'),
        Track(number: 7, title: 'House of Cards', duration: '5:28'),
      ],
    ),
    Album(
      id: 'blue-train',
      title: 'Blue Train',
      artist: 'John Coltrane',
      genres: ['jazz', 'r&b'],
      artistMonthlyListeners: 3100000, // FICTÍCIO: John Coltrane
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '42 min 11 s',
      tracks: [
        Track(number: 1, title: 'Blue Train', duration: '10:43'),
        Track(number: 2, title: "Moment's Notice", duration: '9:10'),
        Track(number: 3, title: 'Locomotion', duration: '7:14'),
        Track(number: 4, title: "I'm Old Fashioned", duration: '7:58'),
        Track(number: 5, title: 'Lazy Bird', duration: '7:06'),
      ],
    ),
    Album(
      id: 'illmatic',
      title: 'Illmatic',
      artist: 'Nas',
      genres: ['hiphop', 'r&b'],
      artistMonthlyListeners: 11000000, // FICTÍCIO: Nas
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '39 min 51 s',
      tracks: [
        Track(number: 1, title: 'The Genesis', duration: '1:45'),
        Track(number: 2, title: 'N.Y. State of Mind', duration: '4:54'),
        Track(number: 3, title: "Life's a Bitch", duration: '3:30'),
        Track(number: 4, title: 'The World Is Yours', duration: '4:50'),
        Track(number: 5, title: 'Halftime', duration: '4:20'),
        Track(number: 6, title: 'Memory Lane', duration: '4:08'),
      ],
    ),
    Album(
      id: 'souvlaki',
      title: 'Souvlaki',
      artist: 'Slowdive',
      genres: ['shoegaze', 'dream-pop'],
      artistMonthlyListeners: 2900000, // FICTÍCIO: Slowdive
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '40 min 40 s',
      tracks: [
        Track(number: 1, title: 'Alison', duration: '3:52'),
        Track(number: 2, title: 'Machine Gun', duration: '4:28'),
        Track(number: 3, title: '40 Days', duration: '3:15'),
        Track(number: 4, title: 'Sing', duration: '4:49'),
        Track(number: 5, title: 'Here She Comes', duration: '2:21'),
        Track(number: 6, title: 'When the Sun Hits', duration: '4:47'),
        Track(number: 7, title: 'Dagger', duration: '3:34'),
      ],
    ),
    Album(
      id: 'bitches-brew',
      title: 'Bitches Brew',
      artist: 'Miles Davis',
      genres: ['jazz', 'rock'],
      artistMonthlyListeners: 4200000, // FICTÍCIO: Miles Davis
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '94 min 11 s',
      tracks: [
        Track(number: 1, title: "Pharaoh's Dance", duration: '20:06'),
        Track(number: 2, title: 'Bitches Brew', duration: '26:58'),
        Track(number: 3, title: 'Spanish Key', duration: '17:32'),
        Track(number: 4, title: 'John McLaughlin', duration: '4:22'),
        Track(number: 5, title: 'Miles Runs the Voodoo Down', duration: '14:01'),
      ],
    ),
    Album(
      id: 'wowee-zowee',
      title: 'Wowee Zowee',
      artist: 'Pavement',
      genres: ['indie', 'rock'],
      artistMonthlyListeners: 1500000, // FICTÍCIO: Pavement
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '55 min 33 s',
      tracks: [
        Track(number: 1, title: 'We Dance', duration: '3:01'),
        Track(number: 2, title: 'Rattled by the Rush', duration: '4:16'),
        Track(number: 3, title: 'Black Out', duration: '2:10'),
        Track(number: 4, title: 'Grounded', duration: '4:14'),
        Track(number: 5, title: 'Father to a Sister of Thought', duration: '3:30'),
      ],
    ),
    Album(
      id: 'vespertine',
      title: 'Vespertine',
      artist: 'Björk',
      genres: ['eletrônica', 'experimental'],
      artistMonthlyListeners: 4100000, // FICTÍCIO: Björk
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '55 min 33 s',
      tracks: [
        Track(number: 1, title: 'Hidden Place', duration: '5:28'),
        Track(number: 2, title: 'Cocoon', duration: '4:28'),
        Track(number: 3, title: "It's Not Up to You", duration: '5:08'),
        Track(number: 4, title: 'Undo', duration: '5:38'),
        Track(number: 5, title: 'Pagan Poetry', duration: '5:14'),
        Track(number: 6, title: 'Unison', duration: '6:45'),
      ],
    ),
    Album(
      id: 'immunity',
      title: 'Immunity',
      artist: 'Clairo',
      genres: ['indie', 'bedroom-pop'],
      artistMonthlyListeners: 17200000, // FICTÍCIO: Clairo
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '40 min 49 s',
      tracks: [
        Track(number: 1, title: 'Alewife', duration: '3:33'),
        Track(number: 2, title: 'Impossible', duration: '3:50'),
        Track(number: 3, title: 'Closer to You', duration: '2:40'),
        Track(number: 4, title: 'North', duration: '3:33'),
        Track(number: 5, title: 'Bags', duration: '4:20'),
        Track(number: 6, title: 'Sofia', duration: '3:08'),
        Track(number: 7, title: 'White Flag', duration: '3:01'),
        Track(number: 8, title: 'Feel Something', duration: '2:57'),
      ],
    ),
    Album(
      id: 'sling',
      title: 'Sling',
      artist: 'Clairo',
      genres: ['indie', 'folk'],
      artistMonthlyListeners: 17200000, // FICTÍCIO: Clairo
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '44 min 28 s',
      tracks: [
        Track(number: 1, title: 'Bambi', duration: '4:37'),
        Track(number: 2, title: 'Amoeba', duration: '3:48'),
        Track(number: 3, title: 'Partridge', duration: '3:13'),
        Track(number: 4, title: 'Zinnias', duration: '2:54'),
        Track(number: 5, title: 'Blouse', duration: '3:15'),
        Track(number: 6, title: 'Harbor', duration: '4:24'),
        Track(number: 7, title: 'Just for Today', duration: '3:37'),
        Track(number: 8, title: 'Reaper', duration: '2:39'),
      ],
    ),
    Album(
      id: 'charm',
      title: 'Charm',
      artist: 'Clairo',
      genres: ['indie', 'bedroom-pop'],
      artistMonthlyListeners: 17200000, // FICTÍCIO: Clairo
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '38 min 14 s',
      tracks: [
        Track(number: 1, title: 'Nomad', duration: '5:04'),
        Track(number: 2, title: 'Sexy to Someone', duration: '3:34'),
        Track(number: 3, title: 'Second Nature', duration: '3:50'),
        Track(number: 4, title: 'Slow Dance', duration: '3:54'),
        Track(number: 5, title: 'Thank You', duration: '4:10'),
        Track(number: 6, title: 'Terrapin', duration: '3:00'),
        Track(number: 7, title: 'Juna', duration: '3:14'),
        Track(number: 8, title: 'Echo', duration: '3:46'),
      ],
    ),
    Album(
      id: 'be-the-cowboy',
      title: 'Be the Cowboy',
      artist: 'Mitski',
      genres: ['indie', 'pop'],
      artistMonthlyListeners: 19800000, // FICTÍCIO: Mitski
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '32 min 28 s',
      tracks: [
        Track(number: 1, title: 'Geyser', duration: '2:23'),
        Track(number: 2, title: "Why Didn't You Stop Me?", duration: '2:21'),
        Track(number: 3, title: 'Old Friend', duration: '1:52'),
        Track(number: 4, title: 'A Pearl', duration: '2:36'),
        Track(number: 5, title: 'Nobody', duration: '3:13'),
        Track(number: 6, title: 'Washing Machine Heart', duration: '2:55'),
        Track(number: 7, title: 'Two Slow Dancers', duration: '3:59'),
      ],
    ),
    Album(
      id: 'teen-dream',
      title: 'Teen Dream',
      artist: 'Beach House',
      genres: ['indie', 'dream-pop'],
      artistMonthlyListeners: 6800000, // FICTÍCIO: Beach House
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '48 min 47 s',
      tracks: [
        Track(number: 1, title: 'Zebra', duration: '4:48'),
        Track(number: 2, title: 'Silver Soul', duration: '4:58'),
        Track(number: 3, title: 'Norway', duration: '3:54'),
        Track(number: 4, title: 'Walk in the Park', duration: '5:22'),
        Track(number: 5, title: 'Used to Be', duration: '4:00'),
        Track(number: 6, title: '10 Mile Stereo', duration: '5:03'),
        Track(number: 7, title: 'Take Care', duration: '5:48'),
      ],
    ),
    Album(
      id: 'clean',
      title: 'Clean',
      artist: 'Soccer Mommy',
      genres: ['indie', 'shoegaze'],
      artistMonthlyListeners: 1200000, // FICTÍCIO: Soccer Mommy
      coverUrl: null,
      aspectRatio: 1.0,
      totalDuration: '35 min 28 s',
      tracks: [
        Track(number: 1, title: 'Still Clean', duration: '3:15'),
        Track(number: 2, title: 'Cool', duration: '2:37'),
        Track(number: 3, title: 'Your Dog', duration: '3:07'),
        Track(number: 4, title: 'Flaw', duration: '3:34'),
        Track(number: 5, title: 'Blossom', duration: '3:15'),
        Track(number: 6, title: 'Scorpio Rising', duration: '4:41'),
      ],
    ),
  ];

  @override
  Future<List<Album>> getAllAlbums() async {
    return List.unmodifiable(_mockAlbums);
  }

  @override
  Future<Album?> getAlbumById(String id) async {
    try {
      return _mockAlbums.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Album>> getAlbumsByGenre(String genre) async {
    final normalizedGenre = genre.trim().toLowerCase();
    return _mockAlbums
        .where((a) => a.genres.any((g) => g.toLowerCase() == normalizedGenre))
        .toList();
  }

  @override
  Future<List<String>> getAllGenres() async {
    final set = <String>{};
    for (final album in _mockAlbums) {
      set.addAll(album.genres);
    }
    final list = set.toList()..sort();
    return list;
  }

  @override
  Future<List<Album>> search(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAllAlbums();

    return _mockAlbums.where((album) {
      final matchesTitle = album.title.toLowerCase().contains(q);
      final matchesArtist = album.artist.toLowerCase().contains(q);
      final matchesGenre = album.genres.any((g) => g.toLowerCase().contains(q));
      return matchesTitle || matchesArtist || matchesGenre;
    }).toList();
  }
}
