import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Etiqueta blanca "● Perro" que va sobre las tarjetas moradas.
class KindBadge extends StatelessWidget {
  const KindBadge({super.key, required this.kind});

  final ProfileKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(kind.label, style: AppTextStyles.chip.copyWith(fontSize: 12.5)),
        ],
      ),
    );
  }
}
