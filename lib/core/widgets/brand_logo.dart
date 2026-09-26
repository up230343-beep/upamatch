import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Logotipo de UpaMatch: cuadrado redondeado con degradado y una huella
/// dentro de un corazón.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: size * 0.28,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.favorite_rounded,
              size: size * 0.56,
              color: AppColors.textOnDark,
            ),
            Padding(
              padding: EdgeInsets.only(top: size * 0.03),
              child: Icon(
                Icons.pets_rounded,
                size: size * 0.26,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
