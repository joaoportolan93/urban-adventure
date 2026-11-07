import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/album_model.dart';
import '../controllers/feed_providers.dart';
import 'deterministic_album_cover.dart';
import 'radial_action_menu.dart';

class AlbumCard extends ConsumerWidget {
  final Album album;

  const AlbumCard({
    super.key,
    required this.album,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedIds = ref.watch(likedAlbumsProvider);
    final isLiked = likedIds.contains(album.id);

    final folders = ref.watch(foldersProvider);
    final isSavedInAnyFolder = folders.any((f) => f.albumIds.contains(album.id));

    return Card(
      color: const Color(0xFF18181C),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Capa do Álbum (Tocar abre a Roda Radial com 6 serviços)
          GestureDetector(
            onTap: () => RadialActionMenu.show(context, album),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.0, // Capas quadradas padrão (sem corte)
                  child: DeterministicAlbumCover(
                    title: album.title,
                    artist: album.artist,
                    coverUrl: album.coverUrl,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                ),
                // Indicador visual de toque sutil para a roda
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Metadados: Título e Artista
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  album.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          // Gêneros Clicáveis (Navega para a página do gênero)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: album.genres.map((genre) {
                return InkWell(
                  onTap: () => context.push('/genre/${Uri.encodeComponent(genre)}'),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#$genre',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Linha de Ações: Curtir (♥) e Salvar em Pasta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Botão de Curtir (♥) - Conta para afinidade
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? const Color(0xFFFF2A55) : Colors.white60,
                    size: 20,
                  ),
                  tooltip: isLiked ? 'Descurtir' : 'Curtir (Afinidade)',
                  onPressed: () {
                    ref.read(likedAlbumsProvider.notifier).toggleLike(album.id);
                  },
                ),

                // Botão Salvar em Pasta - Não conta para afinidade
                IconButton(
                  icon: Icon(
                    isSavedInAnyFolder ? Icons.bookmark : Icons.bookmark_border,
                    color: isSavedInAnyFolder
                        ? const Color(0xFFFFB300)
                        : Colors.white60,
                    size: 20,
                  ),
                  tooltip: 'Salvar em Pasta',
                  onPressed: () => _showFolderSelectionSheet(context, ref),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFolderSelectionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Consumer(
          builder: (context, refConsumer, _) {
            final folders = refConsumer.watch(foldersProvider);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Salvar em Pasta',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Nova pasta'),
                        onPressed: () => _showCreateFolderDialog(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: folders.length,
                      itemBuilder: (context, i) {
                        final folder = folders[i];
                        final isSaved = folder.albumIds.contains(album.id);

                        return ListTile(
                          leading: Icon(
                            folder.name == 'Ouvir depois'
                                ? Icons.access_time_rounded
                                : Icons.folder_rounded,
                            color: isSaved
                                ? const Color(0xFFFFB300)
                                : Colors.white60,
                          ),
                          title: Text(
                            folder.name,
                            style: TextStyle(
                              color: isSaved ? Colors.white : Colors.white70,
                              fontWeight:
                                  isSaved ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            '${folder.albumIds.length} álbuns',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                          trailing: Checkbox(
                            value: isSaved,
                            activeColor: const Color(0xFFFFB300),
                            onChanged: (_) {
                              ref
                                  .read(foldersProvider.notifier)
                                  .toggleAlbumInFolder(folder.id, album.id);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateFolderDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF25252E),
        title: const Text('Criar Nova Pasta', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: textController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Nome da pasta...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                ref.read(foldersProvider.notifier).createFolder(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }
}

