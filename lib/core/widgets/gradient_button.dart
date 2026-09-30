import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Botón principal con el degradado morado de la marca.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 52,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  /// Muestra un indicador en lugar del texto y no deja volver a tocarlo.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(height / 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x337C3AED),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(height / 2),
            onTap: loading ? null : onPressed,
            child: Center(
              child: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: AppColors.textOnDark,
                      ),
                    )
                  : Text(label, style: AppTextStyles.button),
            ),
          ),
        ),
      ),
    );
  }
}
