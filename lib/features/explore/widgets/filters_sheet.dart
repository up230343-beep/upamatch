import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../data/models/explore_filters.dart';

/// 09 · Filtros de Explorar (hoja inferior).
///
/// Devuelve los [ExploreFilters] aplicados, o `null` si se cierra sin aplicar.
Future<ExploreFilters?> showFiltersSheet(
  BuildContext context,
  ExploreFilters current,
) {
  return showModalBottomSheet<ExploreFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    constraints: const BoxConstraints(maxWidth: 430),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusSheet),
      ),
    ),
    builder: (_) => _FiltersSheet(initial: current),
  );
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.initial});

  final ExploreFilters initial;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late ExploreFilters _filters = widget.initial;

  @override
  Widget build(BuildContext context) {
    final sliderTheme = SliderTheme.of(context).copyWith(
      activeTrackColor: AppColors.primary,
      inactiveTrackColor: AppColors.surfaceMuted,
      thumbColor: AppColors.primary,
      overlayColor: AppColors.primary.withValues(alpha: 0.12),
      trackHeight: 4,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.pagePadding,
          10,
          AppTheme.pagePadding,
          16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(
                  child: Text('Filtros', style: AppTextStyles.title),
                ),
                TextButton(
                  onPressed: () =>
                      setState(() => _filters = const ExploreFilters()),
                  child: const Text('Limpiar', style: AppTextStyles.link),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel(
              title: 'Distancia máxima',
              value: '${_filters.maxDistanceKm.round()} km',
            ),
            SliderTheme(
              data: sliderTheme,
              child: Slider(
                min: 1,
                max: ExploreFilters.defaultMaxDistanceKm,
                value: _filters.maxDistanceKm,
                onChanged: (value) => setState(
                  () => _filters = _filters.copyWith(maxDistanceKm: value),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _SectionLabel(
              title: 'Edad',
              value: '${_filters.minAge} – ${_filters.maxAge} años',
            ),
            SliderTheme(
              data: sliderTheme,
              child: RangeSlider(
                min: ExploreFilters.ageLimitMin.toDouble(),
                max: ExploreFilters.ageLimitMax.toDouble(),
                values: RangeValues(
                  _filters.minAge.toDouble(),
                  _filters.maxAge.toDouble(),
                ),
                onChanged: (values) => setState(
                  () => _filters = _filters.copyWith(
                    minAge: values.start.round(),
                    maxAge: values.end.round(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'El tipo de perfil se elige con las píldoras de Explorar.',
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 22),
            GradientButton(
              label: 'Aplicar filtros',
              onPressed: () => Navigator.of(context).pop(_filters),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.sectionTitle)),
        Text(value, style: AppTextStyles.link),
      ],
    );
  }
}
