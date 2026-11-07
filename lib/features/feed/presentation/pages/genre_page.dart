import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/album_model.dart';
import '../../domain/recommendation_engine.dart';
import '../controllers/feed_providers.dart';
import '../widgets/album_masonry_grid.dart';

class GenrePage extends ConsumerStatefulWidget {
  final String genre;

  const GenrePage({
    super.key,
    required this.genre,
  });

  @override
  ConsumerState<GenrePage> createState() => _GenrePageState();
}

class _GenrePageState extends ConsumerState<GenrePage> {
  GenreFilterType? _activeFilter;
  String? _selectedReferenceArtist;

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(catalogAlbumsProvider);
    final likedIds = ref.watch(likedAlbumsProvider);
    final storage = ref.watch(localStorageProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          '#${widget.genre.toLowerCase()}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: catalogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Erro: $err')),
        data: (allAlbums) {
          final genreAlbums = allAlbums
              .where((a) =>
                  a.genres.any((g) => g.toLowerCase() == widget.genre.toLowerCase()))
              .toList();

          final affinityMap = storage.getArtistAffinityMap(allAlbums);

          // Verifica se há afinidade com algum artista do gênero
          final hasAffinityInGenre = genreAlbums.any(
            (a) => (affinityMap[a.artist.toLowerCase()] ?? 0) > 0,
          );

          // Artistas que o usuário já curtiu em todo o catálogo
          final likedArtists = allAlbums
              .where((a) => likedIds.contains(a.id))
              .map((a) => a.artist)
              .toSet()
              .toList()
            ..sort();

          final hasLikedAnyArtist = likedArtists.isNotEmpty;

          // Se o filtro ativo for nulo, a ordem padrão é definida pela especificação:
          // por afinidade (artistas curtidos primeiro); se não houver afinidade, A-Z.
          final List<Album> displayedAlbums;
          if (_activeFilter == null) {
            displayedAlbums = RecommendationEngine.defaultGenreOrder(
              genreAlbums: genreAlbums,
              artistAffinityMap: affinityMap,
            );
          } else {
            switch (_activeFilter!) {
              case GenreFilterType.affinity:
                displayedAlbums = RecommendationEngine.defaultGenreOrder(
                  genreAlbums: genreAlbums,
                  artistAffinityMap: affinityMap,
                );
                break;
              case GenreFilterType.alphabetical:
                displayedAlbums = RecommendationEngine.sortAlphabetical(genreAlbums);
                break;
              case GenreFilterType.mostListeners:
                displayedAlbums = RecommendationEngine.sortMostListeners(genreAlbums);
                break;
              case GenreFilterType.leastListeners:
                displayedAlbums = RecommendationEngine.sortLeastListeners(genreAlbums);
                break;
              case GenreFilterType.similarTo:
                final refArtist = _selectedReferenceArtist ??
                    (likedArtists.isNotEmpty ? likedArtists.first : '');
                displayedAlbums = RecommendationEngine.sortSimilarTo(
                  albums: genreAlbums,
                  referenceArtist: refArtist,
                  allCatalogAlbums: allAlbums,
                );
                break;
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de Filtros da Página do Gênero
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: const Color(0xFF18181F),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Filtro A-Z
                      _buildFilterChip(
                        label: 'A–Z',
                        isSelected: _activeFilter == GenreFilterType.alphabetical ||
                            (_activeFilter == null && !hasAffinityInGenre),
                        onTap: () => setState(() {
                          _activeFilter = GenreFilterType.alphabetical;
                        }),
                      ),

                      // Filtro Por afinidade (Só aparece se houver)
                      if (hasAffinityInGenre)
                        _buildFilterChip(
                          label: 'Por afinidade',
                          isSelected: _activeFilter == GenreFilterType.affinity ||
                              (_activeFilter == null && hasAffinityInGenre),
                          onTap: () => setState(() {
                            _activeFilter = GenreFilterType.affinity;
                          }),
                        ),

                      // Filtro Mais ouvintes
                      _buildFilterChip(
                        label: 'Mais ouvintes',
                        isSelected: _activeFilter == GenreFilterType.mostListeners,
                        onTap: () => setState(() {
                          _activeFilter = GenreFilterType.mostListeners;
                        }),
                      ),

                      // Filtro Menos ouvintes
                      _buildFilterChip(
                        label: 'Menos ouvintes',
                        isSelected: _activeFilter == GenreFilterType.leastListeners,
                        onTap: () => setState(() {
                          _activeFilter = GenreFilterType.leastListeners;
                        }),
                      ),

                      // Filtro "Parecidos com…" (Só aparece se o usuário já curtiu algum artista)
                      if (hasLikedAnyArtist)
                        _buildFilterChip(
                          label: _selectedReferenceArtist != null
                              ? 'Parecidos com: $_selectedReferenceArtist'
                              : 'Parecidos com…',
                          isSelected: _activeFilter == GenreFilterType.similarTo,
                          onTap: () => _showReferenceArtistPicker(
                            context,
                            likedArtists,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Grade de Álbuns
              Expanded(
                child: AlbumMasonryGrid(albums: displayedAlbums),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: const Color(0xFFFF2A55),
        backgroundColor: Colors.white.withValues(alpha: 0.08),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showReferenceArtistPicker(
    BuildContext context,
    List<String> likedArtists,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      builder: (ctx) => ListView.builder(
        shrinkWrap: true,
        itemCount: likedArtists.length,
        itemBuilder: (context, i) {
          final artist = likedArtists[i];
          return ListTile(
            title: Text(artist, style: const TextStyle(color: Colors.white)),
            onTap: () {
              setState(() {
                _selectedReferenceArtist = artist;
                _activeFilter = GenreFilterType.similarTo;
              });
              Navigator.pop(ctx);
            },
          );
        },
      ),
    );
  }
}

