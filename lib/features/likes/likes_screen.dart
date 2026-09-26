import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Pestaña "Likes".
///
/// El mockup de Figma no incluye esta pantalla todavía, así que se muestra un
/// estado vacío con el mismo estilo para que la barra inferior no tenga una
/// pestaña muerta.
///
/// TODO(backend): listar aquí a quienes dieron like a tu perfil.
class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Flexible(
                child: Text(
                  'Likes',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
              ),
            ],
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    size: 40,
                    color: AppColors.primaryLight,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Aún no hay likes nuevos',
                  style: AppTextStyles.sectionTitle,
                ),
                const SizedBox(height: 6),
                const Text(
                  'Cuando alguien dé like a tu perfil aparecerá aquí.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
