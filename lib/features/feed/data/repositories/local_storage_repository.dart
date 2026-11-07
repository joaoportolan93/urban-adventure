import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import '../models/album_model.dart';
import '../models/folder_model.dart';

class LocalStorageRepository {
  static const String _likesBoxName = 'user_likes';
  static const String _foldersBoxName = 'user_folders';

  late Box<bool> _likesBox;
  late Box<Map> _foldersBox;
  bool _isInitialized = false;

  Future<void> init({String? customPath}) async {
    if (_isInitialized) return;

    if (customPath != null) {
      Hive.init(customPath);
    } else {
      await Hive.initFlutter();
    }
    _likesBox = await Hive.openBox<bool>(_likesBoxName);
    _foldersBox = await Hive.openBox<Map>(_foldersBoxName);

    // Garante que a pasta padrão "Ouvir depois" exista
    if (_foldersBox.isEmpty) {
      final defaultFolder = Folder.createDefault();
      await _foldersBox.put(defaultFolder.id, defaultFolder.toMap());
    }

    _isInitialized = true;
  }

  // --- CURTIDAS (♥) E AFINIDADE ---

  bool isLiked(String albumId) {
    return _likesBox.get(albumId) ?? false;
  }

  Future<bool> toggleLike(String albumId) async {
    final current = isLiked(albumId);
    final newState = !current;
    if (newState) {
      await _likesBox.put(albumId, true);
    } else {
      await _likesBox.delete(albumId);
    }
    return newState;
  }

  Set<String> getLikedAlbumIds() {
    return _likesBox.keys.cast<String>().toSet();
  }

  /// Afinidade = número de álbuns curtidos (♥) do artista.
  /// Salvar em pasta NÃO conta.
  int calculateArtistAffinity(String artist, List<Album> allAlbums) {
    final likedIds = getLikedAlbumIds();
    return allAlbums
        .where((album) =>
            album.artist.toLowerCase() == artist.toLowerCase() &&
            likedIds.contains(album.id))
        .length;
  }

  /// Mapa de afinidade computado para todos os artistas do catálogo
  Map<String, int> getArtistAffinityMap(List<Album> allAlbums) {
    final likedIds = getLikedAlbumIds();
    final map = <String, int>{};

    for (final album in allAlbums) {
      if (likedIds.contains(album.id)) {
        final artistKey = album.artist.toLowerCase();
        map[artistKey] = (map[artistKey] ?? 0) + 1;
      }
    }
    return map;
  }

  // --- PASTAS (FOLDERS) ---

  List<Folder> getFolders() {
    final folders = <Folder>[];
    for (final key in _foldersBox.keys) {
      final data = _foldersBox.get(key);
      if (data != null) {
        folders.add(Folder.fromMap(Map<dynamic, dynamic>.from(data)));
      }
    }
    folders.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return folders;
  }

  Folder? getFolderById(String id) {
    final data = _foldersBox.get(id);
    if (data == null) return null;
    return Folder.fromMap(Map<dynamic, dynamic>.from(data));
  }

  Future<Folder> createFolder(String name) async {
    final id = 'folder_${DateTime.now().millisecondsSinceEpoch}';
    final newFolder = Folder(
      id: id,
      name: name.trim().isEmpty ? Folder.defaultFolderName : name.trim(),
      albumIds: const [],
      createdAt: DateTime.now(),
    );
    await _foldersBox.put(newFolder.id, newFolder.toMap());
    return newFolder;
  }

  Future<void> toggleAlbumInFolder(String folderId, String albumId) async {
    final folder = getFolderById(folderId);
    if (folder == null) return;

    final updatedIds = List<String>.from(folder.albumIds);
    if (updatedIds.contains(albumId)) {
      updatedIds.remove(albumId);
    } else {
      updatedIds.add(albumId);
    }

    final updatedFolder = folder.copyWith(albumIds: updatedIds);
    await _foldersBox.put(folderId, updatedFolder.toMap());
  }

  Future<void> deleteFolder(String folderId) async {
    // Não permite apagar a pasta padrão
    if (folderId == 'default_listen_later') return;
    await _foldersBox.delete(folderId);
  }
}
