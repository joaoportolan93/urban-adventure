import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/feed_providers.dart';
import '../widgets/album_masonry_grid.dart';
import 'library_page.dart';

class FeedPage extends ConsumerStatefulWidget {
  const FeedPage({super.key});

  @override
  ConsumerState<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends ConsumerState<FeedPage> {
  int _currentTabIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchSubmit(String text, BuildContext context) async {
    final query = text.trim().toLowerCase();
    if (query.isEmpty) return;

    // Se o texto for exatamente o nome de um gênero, abre a página dele codificada
    final catalog = await ref.read(musicRepositoryProvider).getAllAlbums();
    final allGenres = catalog
        .expand((a) => a.genres)
        .map((g) => g.toLowerCase())
        .toSet();

    if (allGenres.contains(query) && context.mounted) {
      context.push('/genre/${Uri.encodeComponent(query)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentTabIndex == 1) {
      return Scaffold(
        body: const LibraryPage(),
        bottomNavigationBar: _buildBottomNav(),
      );
    }

    final filteredAlbumsAsync = ref.watch(searchFilteredAlbumsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF111115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF18181F),
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(
              Icons.blur_on_rounded,
              color: Color(0xFFFF2A55),
              size: 26,
            ),
            const SizedBox(width: 8),
            const Text(
              'DISCOVERY',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            // Botão "Atualizar feed" (reordena por afinidade + exploração + inéditos)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Atualizar feed (Gosto + Exploração)',
              onPressed: () {
                ref.read(feedAlbumsProvider.notifier).refreshFeed();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Feed reordenado com novas recomendações!'),
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).setQuery(val);
              },
              onSubmitted: (val) => _handleSearchSubmit(val, context),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar álbum, artista ou gênero (ex: shoegaze)...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
                prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF22222B),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: filteredAlbumsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFFFF2A55)),
        ),
        error: (err, _) => Center(
          child: Text('Erro ao carregar catálogo: $err',
              style: const TextStyle(color: Colors.white70)),
        ),
        data: (albums) => AlbumMasonryGrid(albums: albums),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: (index) => setState(() => _currentTabIndex = index),
      backgroundColor: const Color(0xFF18181F),
      selectedItemColor: const Color(0xFFFF2A55),
      unselectedItemColor: Colors.white38,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_rounded),
          label: 'Descobrir',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_rounded),
          label: 'Salvos (Flow)',
        ),
      ],
    );
  }
}
