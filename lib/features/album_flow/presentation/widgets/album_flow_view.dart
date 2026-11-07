import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:urban_adventure/features/feed/data/models/album_model.dart';
import 'package:urban_adventure/features/feed/presentation/widgets/deterministic_album_cover.dart';
import 'package:urban_adventure/features/feed/presentation/widgets/radial_action_menu.dart';

/// Efeito "Album Flow" (N10) idêntico ao exemplo diegoveloper/flutter-samples:
/// Pilha vertical de capas sobrepostas com perspectiva 3D em gaveta de vinil (Matrix4),
/// exibindo nomes das faixas, durações e gêneros.
class AlbumFlowView extends StatefulWidget {
  final List<Album> albums;
  final VoidCallback? onBack;
  final String title;

  const AlbumFlowView({
    super.key,
    required this.albums,
    this.onBack,
    this.title = 'Albums',
  });

  @override
  State<AlbumFlowView> createState() => _AlbumFlowViewState();
}

class _AlbumFlowViewState extends State<AlbumFlowView> {
  late final PageController _pageController;
  double _currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.32, // Permite sobreposição e visibilidade de múltiplos itens
      initialPage: 0,
    );
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0.0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showAlbumDetails(BuildContext context, Album album) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141419),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Puxador central
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                // Cabeçalho: Título, Artista e Duração Total
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: DeterministicAlbumCover(
                        title: album.title,
                        artist: album.artist,
                        coverUrl: album.coverUrl,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            album.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            album.artist,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 14,
                                color: Color(0xFFFF2A55),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${album.totalDuration} • ${album.tracks.length} faixas',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2A55),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      tooltip: 'Abrir Serviços de Streaming',
                      onPressed: () {
                        Navigator.pop(ctx);
                        RadialActionMenu.show(context, album);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Gêneros Clicáveis do Álbum
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: album.genres.map((g) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        context.push('/genre/${Uri.encodeComponent(g)}');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          '#$g',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const Divider(color: Colors.white12, height: 28),

                // Lista de Músicas com Tempo de Duração
                const Text(
                  'Faixas do Álbum',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: album.tracks.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.white10,
                    height: 1,
                  ),
                  itemBuilder: (context, i) {
                    final track = album.tracks[i];
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: SizedBox(
                        width: 24,
                        child: Text(
                          track.number.toString().padLeft(2, '0'),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        track.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        track.duration,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.albums.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: widget.onBack != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: widget.onBack,
                )
              : null,
          title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text(
            'Nenhum álbum nesta pasta.',
            style: TextStyle(color: Colors.white60),
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = math.min(screenWidth * 0.88, 380.0);

    return Scaffold(
      backgroundColor: Colors.black, // Fundo preto puro igual ao mockup de referência
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: widget.onBack,
              )
            : null,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70),
            tooltip: 'Detalhes do Álbum em Foco',
            onPressed: () {
              final activeIndex = _currentPage.round().clamp(0, widget.albums.length - 1);
              _showAlbumDetails(context, widget.albums[activeIndex]);
            },
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // PageView invisível para captura nativa de scroll vertical suave
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.albums.length,
            itemBuilder: (context, index) => const SizedBox.expand(),
          ),

          // Renderização das capas sobrepostas com perspectiva 3D em leque
          IgnorePointer(
            ignoring: false,
            child: Center(
              child: SizedBox(
                width: cardWidth,
                height: 480,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: List.generate(widget.albums.length, (index) {
                    final album = widget.albums[index];
                    final diff = index - _currentPage;

                    // Oculta itens muito distantes para otimizar desempenho
                    if (diff < -1.2 || diff > 4.5) {
                      return const SizedBox.shrink();
                    }

                    // Cálculo da matriz 3D da pilha inclinada (Album Flow)
                    final Matrix4 matrix = Matrix4.identity()
                      ..setEntry(3, 2, 0.0018); // Perspectiva z

                    double opacity = 1.0;
                    double yTranslate = 0.0;

                    if (diff < 0) {
                      // Cartões que já passaram deslizam para cima e desaparecem
                      yTranslate = diff * 190.0;
                      opacity = (1.0 + diff).clamp(0.0, 1.0);
                      matrix.translateByDouble(0.0, yTranslate, 0.0, 1.0);
                    } else {
                      // Cartões na gaveta: inclinam para trás em perspectiva e sobrepõem-se
                      yTranslate = diff * 75.0; // Espaçamento vertical comprimido
                      final angle = (diff * 0.42).clamp(0.0, 1.25); // Rotação X progressiva
                      final scale = (1.0 - (diff * 0.04)).clamp(0.7, 1.0);

                      matrix.translateByDouble(0.0, yTranslate, 0.0, 1.0);
                      matrix.rotateX(angle);
                      matrix.scaleByDouble(scale, scale, 1.0, 1.0);

                      // Ocultamento gradual no fundo da pilha
                      opacity = (1.0 - (diff * 0.18)).clamp(0.2, 1.0);
                    }

                    return Positioned(
                      top: 40,
                      child: Transform(
                        alignment: Alignment.topCenter,
                        transform: matrix,
                        child: Opacity(
                          opacity: opacity,
                          child: GestureDetector(
                            onTap: () => _showAlbumDetails(context, album),
                            child: Container(
                              width: cardWidth,
                              height: cardWidth, // Capa quadrada 1:1
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.8),
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1.5, // Brilho superior característico
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    DeterministicAlbumCover(
                                      title: album.title,
                                      artist: album.artist,
                                      coverUrl: album.coverUrl,
                                    ),
                                    // Sombra sutil de profundidade
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withValues(
                                              alpha: (diff * 0.2).clamp(0.0, 0.6),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).reversed.toList(), // Inverte para que o cartão superior fique no topo da pilha
                ),
              ),
            ),
          ),

          // Dica inferior de interação
          Positioned(
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app_rounded, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Deslize para navegar • Toque para ver faixas',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
