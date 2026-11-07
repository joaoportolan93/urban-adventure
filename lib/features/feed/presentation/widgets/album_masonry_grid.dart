import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../data/models/album_model.dart';
import 'album_card.dart';

class AlbumMasonryGrid extends StatelessWidget {
  final List<Album> albums;
  final ScrollController? scrollController;
  final EdgeInsetsGeometry padding;

  const AlbumMasonryGrid({
    super.key,
    required this.albums,
    this.scrollController,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.album_outlined,
                size: 64,
                color: Colors.white.withValues(alpha: 0.25),
              ),
              const SizedBox(height: 16),
              const Text(
                'Nenhum álbum encontrado.',
                style: TextStyle(color: Colors.white60, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    // Colunas via responsive_framework sem autoScale:
    // 2 no celular, 3 no tablet, 5 no desktop
    final int crossAxisCount = ResponsiveBreakpoints.of(context).isMobile
        ? 2
        : ResponsiveBreakpoints.of(context).isTablet
            ? 3
            : 5;

    return MasonryGridView.count(
      controller: scrollController,
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: padding,
      itemCount: albums.length,
      itemBuilder: (context, index) {
        return AlbumCard(album: albums[index]);
      },
    );
  }
}
