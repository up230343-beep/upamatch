import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum _PillVariant { filter, choice, glass }

/// Píldora reutilizable. El mockup usa tres variantes:
///
/// * [PillChip.filter] → filtros de "Explorar" (seleccionada = morado oscuro).
/// * [PillChip.choice] → "¿Qué buscas?" (seleccionada = borde y texto morado).
/// * [PillChip.glass]  → etiquetas translúcidas sobre la tarjeta de perfil.
class PillChip extends StatelessWidget {
  const PillChip._(
    this._variant, {
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  const PillChip.filter({
    Key? key,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) : this._(
          _PillVariant.filter,
          key: key,
          label: label,
          selected: selected,
          onTap: onTap,
        );

  const PillChip.choice({
    Key? key,
    required String label,
    bool selected = false,
    VoidCallback? onTap,
  }) : this._(
          _PillVariant.choice,
          key: key,
          label: label,
          selected: selected,
          onTap: onTap,
        );

  const PillChip.glass({Key? key, required String label})
      : this._(
          _PillVariant.glass,
          key: key,
          label: label,
          selected: false,
          onTap: null,
        );

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final _PillVariant _variant;

  @override
  Widget build(BuildContext context) {
    final (Color background, Color borderColor, Color textColor) = switch ((
      _variant,
      selected,
    )) {
      (_PillVariant.filter, true) => (
          AppColors.dark,
          AppColors.dark,
          AppColors.textOnDark,
        ),
      (_PillVariant.choice, true) => (
          AppColors.surface,
          AppColors.primaryLight,
          AppColors.primary,
        ),
      (_PillVariant.glass, _) => (
          const Color(0x33FFFFFF),
          const Color(0x4DFFFFFF),
          AppColors.textOnDark,
        ),
      _ => (AppColors.surface, AppColors.border, AppColors.textPrimary),
    };

    // Ojo: nada de `alignment` en el Container; con restricciones acotadas
    // haría que la píldora se estirase a todo el ancho disponible.
    final pill = Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor, width: selected ? 1.4 : 1),
      ),
      child: Center(
        widthFactor: 1,
        child: Text(
          label,
          style: AppTextStyles.chip.copyWith(color: textColor),
        ),
      ),
    );

    if (onTap == null) return pill;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: pill,
      ),
    );
  }
}
