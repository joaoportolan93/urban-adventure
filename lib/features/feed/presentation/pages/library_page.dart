import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/folder_model.dart';
import '../../../album_flow/presentation/widgets/album_flow_view.dart';
import '../controllers/feed_providers.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  Folder? _activeFolderForFlow;

  @override
  Widget build(BuildContext context) {
    final folders = ref.watch(foldersProvider);
    final catalogAsync = ref.watch(catalogAlbumsProvider);

    return catalogAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Erro: $err')),
      data: (allAlbums) {
        // Se uma pasta estiver aberta, exibe o Album Flow com efeito 3D
        if (_activeFolderForFlow != null) {
          final folder = folders.firstWhere(
            (f) => f.id == _activeFolderForFlow!.id,
            orElse: () => _activeFolderForFlow!,
          );

          final folderAlbums = allAlbums
              .where((a) => folder.albumIds.contains(a.id))
              .toList();

          return AlbumFlowView(
            title: folder.name,
            albums: folderAlbums,
            onBack: () => setState(() => _activeFolderForFlow = null),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF111115),
          appBar: AppBar(
            backgroundColor: const Color(0xFF18181F),
            elevation: 0,
            title: const Text(
              'Pastas e Salvos',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.create_new_folder_outlined, color: Colors.white),
                tooltip: 'Nova Pasta',
                onPressed: () => _showCreateFolderDialog(context),
              ),
            ],
          ),
          body: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: folders.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final folder = folders[index];
              final albumCount = folder.albumIds.length;

              return Card(
                color: const Color(0xFF1C1C24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: folder.name == Folder.defaultFolderName
                          ? const Color(0xFFFF2A55).withValues(alpha: 0.15)
                          : const Color(0xFFFFB300).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      folder.name == Folder.defaultFolderName
                          ? Icons.access_time_rounded
                          : Icons.folder_special_rounded,
                      color: folder.name == Folder.defaultFolderName
                          ? const Color(0xFFFF2A55)
                          : const Color(0xFFFFB300),
                    ),
                  ),
                  title: Text(
                    folder.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    '$albumCount ${albumCount == 1 ? 'álbum' : 'álbuns'} • Toque para Album Flow',
                    style: const TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white30,
                    size: 16,
                  ),
                  onTap: () {
                    setState(() {
                      _activeFolderForFlow = folder;
                    });
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
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
