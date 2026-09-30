import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';

/// Aviso rojo con el error de un formulario ("Correo o contraseña
/// incorrectos."). No pinta nada si [mensaje] es `null`.
class FormError extends StatelessWidget {
  const FormError({super.key, required this.mensaje});

  final String? mensaje;

  @override
  Widget build(BuildContext context) {
    final texto = mensaje;
    if (texto == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.danger.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 19,
            color: AppColors.danger,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: AppTextStyles.body.copyWith(
                fontSize: 13.5,
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
