import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barra de avance del registro ("Paso 1 de 2").
class StepProgressBar extends StatelessWidget {
  const StepProgressBar({super.key, required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            const ColoredBox(
              color: AppColors.surfaceMuted,
              child: SizedBox(width: double.infinity, height: 6),
            ),
            FractionallySizedBox(
              widthFactor: step / total,
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: SizedBox(height: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
