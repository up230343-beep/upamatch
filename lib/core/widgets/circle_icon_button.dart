import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Botón circular blanco con borde fino, usado en las cabeceras y en el
/// "volver" del registro.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 38,
    this.iconSize = 19,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;

  /// Punto morado de "hay novedades" (campana de Explorar).
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: iconSize, color: AppColors.textPrimary),
            ),
          ),
        ),
        if (showDot)
          Positioned(
            top: 1,
            right: 1,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
