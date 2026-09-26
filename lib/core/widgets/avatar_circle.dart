import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Avatar circular del mockup: fondo lila, aro morado y el hueco de la foto.
///
/// TODO(backend): cuando llegue `photoUrl` se pinta la imagen real; mientras
/// tanto se muestra el marcador, igual que en Figma.
class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    this.size = 54,
    this.photoUrl,
    this.emoji,
    this.showRing = true,
    this.online = false,
  });

  final double size;
  final String? photoUrl;
  final String? emoji;
  final bool showRing;
  final bool online;

  @override
  Widget build(BuildContext context) {
    final dotSize = size * 0.26;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
              border: showRing
                  ? Border.all(color: AppColors.primaryLight, width: 1.6)
                  : null,
            ),
            child: _content(),
          ),
          if (online)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF3CC97F),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _content() {
    if (photoUrl != null) {
      return Image.network(photoUrl!, fit: BoxFit.cover);
    }
    if (emoji != null) {
      return Center(
        child: Text(emoji!, style: TextStyle(fontSize: size * 0.46)),
      );
    }
    return Icon(
      Icons.image_outlined,
      size: size * 0.4,
      color: AppColors.primary,
    );
  }
}
