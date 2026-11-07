import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class DeterministicAlbumCover extends StatelessWidget {
  final String title;
  final String artist;
  final String? coverUrl;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const DeterministicAlbumCover({
    super.key,
    required this.title,
    required this.artist,
    this.coverUrl,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(12);

    final hasNetworkUrl = coverUrl != null &&
        coverUrl!.trim().isNotEmpty &&
        coverUrl!.startsWith('http');

    if (hasNetworkUrl) {
      return ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: CachedNetworkImage(
          imageUrl: coverUrl!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildDeterministic(context),
        ),
      );
    }

    return ClipRRect(
      borderRadius: effectiveBorderRadius,
      child: _buildDeterministic(context),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFF1E1E24),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white38),
          ),
        ),
      ),
    );
  }

  Widget _buildDeterministic(BuildContext context) {
    final seed = (title + artist).codeUnits.fold<int>(0, (prev, c) => prev + c);
    final palettes = _deterministicPalettes;
    final palette = palettes[seed % palettes.length];

    final initials = _extractInitials(title);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.start, palette.end],
        ),
      ),
      child: Stack(
        children: [
          // Padrão geométrico de vinil determinístico
          Positioned(
            right: -20,
            bottom: -20,
            child: Opacity(
              opacity: 0.18,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 8),
                ),
                child: Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tipografia estilosa de capa
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Iniciais / Monograma do Álbum
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                // Título e Artista na base
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black45,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _extractInitials(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return 'LP';
    if (words.length == 1) {
      return words.first.substring(0, words.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  static const List<_ColorPair> _deterministicPalettes = [
    _ColorPair(Color(0xFF1E3C72), Color(0xFF2A5298)), // Deep Indigo
    _ColorPair(Color(0xFF8A2387), Color(0xFFE94057)), // Purple Crimson
    _ColorPair(Color(0xFF0F2027), Color(0xFF203A43)), // Dark Slate Cyan
    _ColorPair(Color(0xFF134E5E), Color(0xFF71B280)), // Emerald Pine
    _ColorPair(Color(0xFF4B1248), Color(0xFFF0C27B)), // Velvet Gold
    _ColorPair(Color(0xFF2C3E50), Color(0xFFFD746C)), // Midnight Coral
    _ColorPair(Color(0xFF3A1C71), Color(0xFFD76D77)), // Amethyst Sunset
    _ColorPair(Color(0xFF1F1C18), Color(0xFF8E0E00)), // Obsidian Ruby
  ];
}

class _ColorPair {
  final Color start;
  final Color end;
  const _ColorPair(this.start, this.end);
}
