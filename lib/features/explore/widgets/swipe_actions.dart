import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Fila de acciones que se monta sobre el borde inferior de la tarjeta:
/// pasar, dar like y super like.
class SwipeActions extends StatelessWidget {
  const SwipeActions({
    super.key,
    this.onSkip,
    this.onLike,
    this.onSuperLike,
  });

  final VoidCallback? onSkip;
  final VoidCallback? onLike;
  final VoidCallback? onSuperLike;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _ActionButton(
          size: 52,
          icon: Icons.close_rounded,
          iconSize: 26,
          iconColor: AppColors.danger,
          onTap: onSkip,
        ),
        const SizedBox(width: 18),
        _ActionButton(
          size: 64,
          icon: Icons.favorite_rounded,
          iconSize: 30,
          iconColor: AppColors.textOnDark,
          gradient: AppColors.primaryGradient,
          onTap: onLike,
        ),
        const SizedBox(width: 18),
        _ActionButton(
          size: 52,
          icon: Icons.star_rounded,
          iconSize: 28,
          iconColor: AppColors.star,
          onTap: onSuperLike,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.size,
    required this.icon,
    required this.iconSize,
    required this.iconColor,
    this.gradient,
    this.onTap,
  });

  final double size;
  final IconData icon;
  final double iconSize;
  final Color iconColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: gradient == null ? AppColors.surface : null,
        gradient: gradient,
        shape: BoxShape.circle,
        boxShadow: AppColors.floatingShadow,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Icon(icon, size: iconSize, color: iconColor),
        ),
      ),
    );
  }
}
