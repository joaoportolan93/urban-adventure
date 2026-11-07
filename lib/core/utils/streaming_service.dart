import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum StreamingService {
  spotify('Spotify', 'spotify'),
  youtubeMusic('YouTube Music', 'ytmusic'),
  appleMusic('Apple Music', 'apple'),
  deezer('Deezer', 'deezer'),
  tidal('Tidal', 'tidal'),
  bandcamp('Bandcamp', 'bandcamp');

  final String label;
  final String keyName;

  const StreamingService(this.label, this.keyName);

  Uri buildSearchUri(String artist, String album) {
    final query = Uri.encodeComponent('$artist $album');
    switch (this) {
      case StreamingService.spotify:
        return Uri.parse('https://open.spotify.com/search/$query');
      case StreamingService.youtubeMusic:
        return Uri.parse('https://music.youtube.com/search?q=$query');
      case StreamingService.appleMusic:
        return Uri.parse('https://music.apple.com/us/search?term=$query');
      case StreamingService.deezer:
        return Uri.parse('https://www.deezer.com/search/$query');
      case StreamingService.tidal:
        return Uri.parse('https://listen.tidal.com/search?q=$query');
      case StreamingService.bandcamp:
        return Uri.parse('https://bandcamp.com/search?q=$query');
    }
  }

  /// Abre a busca do serviço diretamente via launchUrl (sem canLaunchUrl)
  /// e trata a falha conforme exigido pela especificação.
  Future<bool> launchSearch(String artist, String album) async {
    final uri = buildSearchUri(artist, album);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Fallback para navegador integrado se app externo não abrir
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      return launched;
    } catch (e) {
      debugPrint('Falha ao abrir $label ($uri): $e');
      return false;
    }
  }
}

