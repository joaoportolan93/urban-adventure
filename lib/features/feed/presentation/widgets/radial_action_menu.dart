import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/utils/streaming_service.dart';
import '../../data/models/album_model.dart';

class RadialActionMenu extends StatefulWidget {
  final Album album;
  final VoidCallback onClose;

  const RadialActionMenu({
    super.key,
    required this.album,
    required this.onClose,
  });

  static void show(BuildContext context, Album album) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => RadialActionMenu(
        album: album,
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  State<RadialActionMenu> createState() => _RadialActionMenuState();
}

class _RadialActionMenuState extends State<RadialActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _itemAnimations;

  final List<_ServiceMeta> _services = const [
    _ServiceMeta(
      service: StreamingService.spotify,
      color: Color(0xFF1DB954),
      icon: Icons.music_note,
    ),
    _ServiceMeta(
      service: StreamingService.youtubeMusic,
      color: Color(0xFFFF0000),
      icon: Icons.play_circle_fill,
    ),
    _ServiceMeta(
      service: StreamingService.appleMusic,
      color: Color(0xFFFA243C),
      icon: Icons.apple,
    ),
    _ServiceMeta(
      service: StreamingService.deezer,
      color: Color(0xFFA238FF),
      icon: Icons.equalizer,
    ),
    _ServiceMeta(
      service: StreamingService.tidal,
      color: Color(0xFF00FFFF),
      icon: Icons.waves,
    ),
    _ServiceMeta(
      service: StreamingService.bandcamp,
      color: Color(0xFF1DA0C3),
      icon: Icons.album,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Mola escalonada para os 6 itens (staggered spring)
    _itemAnimations = List.generate(_services.length, (index) {
      final start = (index * 0.08).clamp(0.0, 0.5);
      final end = (start + 0.5).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(start, end, curve: Curves.elasticOut),
      );
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleServiceTap(StreamingService service) async {
    widget.onClose();
    await service.launchSearch(widget.album.artist, widget.album.title);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final radius = (math.min(screenSize.width, screenSize.height) * 0.28)
        .clamp(95.0, 135.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onClose,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador do Álbum selecionado
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E24).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  '${widget.album.title} • ${widget.album.artist}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Roda Radial com 6 botões e botão fechar central
              SizedBox(
                width: (radius * 2) + 80,
                height: (radius * 2) + 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Anel orbital decorativo
                    Container(
                      width: radius * 2,
                      height: radius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                          width: 2,
                        ),
                      ),
                    ),

                    // 6 itens disparados com animação de mola
                    ...List.generate(_services.length, (i) {
                      final meta = _services[i];
                      // Distribuição uniforme em 360° iniciando no topo (-pi/2)
                      final angle = (-math.pi / 2) + (i * (2 * math.pi / _services.length));

                      return AnimatedBuilder(
                        animation: _itemAnimations[i],
                        builder: (context, child) {
                          final progress = _itemAnimations[i].value;
                          final currentRadius = radius * progress;
                          final x = currentRadius * math.cos(angle);
                          final y = currentRadius * math.sin(angle);

                          return Transform.translate(
                            offset: Offset(x, y),
                            child: Opacity(
                              opacity: progress.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: _RadialItemButton(
                          meta: meta,
                          onTap: () => _handleServiceTap(meta.service),
                        ),
                      );
                    }),

                    // Botão Central de Fechar
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _controller,
                        curve: Curves.easeOutBack,
                      ),
                      child: Material(
                        color: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 8,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: widget.onClose,
                          child: const SizedBox(
                            width: 52,
                            height: 52,
                            child: Icon(
                              Icons.close,
                              color: Colors.black87,
                              size: 26,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadialItemButton extends StatefulWidget {
  final _ServiceMeta meta;
  final VoidCallback onTap;

  const _RadialItemButton({
    required this.meta,
    required this.onTap,
  });

  @override
  State<_RadialItemButton> createState() => _RadialItemButtonState();
}

class _RadialItemButtonState extends State<_RadialItemButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: 'Buscar no ${widget.meta.service.label}',
        child: AnimatedScale(
          scale: _isHovered ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Material(
            color: widget.meta.color,
            shape: const CircleBorder(),
            elevation: _isHovered ? 10 : 5,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: widget.onTap,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  widget.meta.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceMeta {
  final StreamingService service;
  final Color color;
  final IconData icon;

  const _ServiceMeta({
    required this.service,
    required this.color,
    required this.icon,
  });
}

