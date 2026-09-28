import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_strip.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/explore_filters.dart';
import '../../data/models/profile.dart';
import '../../data/models/swipe_decision.dart';
import '../../routes/app_routes.dart';
import '../match/match_dialog.dart';
import 'widgets/filters_sheet.dart';
import 'widgets/profile_card.dart';
import 'widgets/swipe_actions.dart';

/// 03 · Explorar perfiles
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const double _actionsOverlap = 30;

  String _filter = MockData.exploreFilters.keys.first;
  ExploreFilters _filters = const ExploreFilters();

  /// Perfiles a los que ya se les dio like o se pasaron en esta sesión.
  ///
  /// TODO(backend): el API ya no debería devolverlos.
  final Set<String> _decided = {};

  List<Profile> get _queue {
    final kind = MockData.exploreFilters[_filter];
    return MockData.profiles
        .where((p) =>
            !_decided.contains(p.id) &&
            (kind == null || p.kind == kind) &&
            _filters.matches(p))
        .toList();
  }

  Future<void> _decide(Profile profile, SwipeDecision decision) async {
    setState(() => _decided.add(profile.id));
    await sendDecision(context, profile, decision);
  }

  Future<void> _openDetail(Profile profile) async {
    final decision = await Navigator.of(context).pushNamed(
      AppRoutes.profileDetail,
      arguments: profile,
    );
    if (decision is SwipeDecision && mounted) {
      await _decide(profile, decision);
    }
  }

  Future<void> _openFilters() async {
    final filters = await showFiltersSheet(context, _filters);
    if (filters != null) setState(() => _filters = filters);
  }

  @override
  Widget build(BuildContext context) {
    final queue = _queue;
    final profile = queue.isEmpty ? null : queue.first;

    return Column(
      children: [
        _ExploreHeader(
          filtersActive: !_filters.isDefault,
          onFilters: _openFilters,
        ),
        const SizedBox(height: 12),
        _FilterBar(
          selected: _filter,
          onChanged: (value) => setState(() => _filter = value),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // La tarjeta ocupa el alto libre, dejando sitio a la fila
              // "Nuevos cerca de ti" y sus separaciones, igual que en el
              // mockup (390 x 844).
              const nearbySectionHeight = 156.0;
              final cardHeight = (constraints.maxHeight -
                      nearbySectionHeight -
                      _actionsOverlap)
                  .clamp(300.0, 460.0);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.pagePadding,
                            0,
                            AppTheme.pagePadding,
                            _actionsOverlap,
                          ),
                          child: SizedBox(
                            height: cardHeight,
                            child: profile == null
                                ? _NoMoreProfiles(
                                    onRestart: () => setState(_decided.clear),
                                  )
                                : GestureDetector(
                                    onTap: () => _openDetail(profile),
                                    child: ProfileCard(
                                      key: ValueKey(profile.id),
                                      profile: profile,
                                    ),
                                  ),
                          ),
                        ),
                        if (profile != null)
                          SwipeActions(
                            onSkip: () => _decide(profile, SwipeDecision.skip),
                            onLike: () => _decide(profile, SwipeDecision.like),
                            onSuperLike: () =>
                                _decide(profile, SwipeDecision.superLike),
                          ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AvatarStrip(
                      title: 'Nuevos cerca de ti',
                      profiles: MockData.nearby,
                      onAction: () {},
                      onTapProfile: (nearby) {
                        final match = MockData.profileById(nearby.id);
                        if (match != null) _openDetail(match);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Se acabaron los perfiles con el filtro actual.
class _NoMoreProfiles extends StatelessWidget {
  const _NoMoreProfiles({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.pets_rounded,
              size: 36,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ya viste a todos por aquí',
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 6),
          const Text(
            'Cambia los filtros o vuelve a ver los perfiles que pasaste.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: onRestart,
            child: const Text('Volver a empezar', style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.filtersActive, required this.onFilters});

  final bool filtersActive;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Row(
        children: [
          const BrandLogo(size: 34),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'UpaMatch',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          CircleIconButton(
            icon: Icons.tune_rounded,
            showDot: filtersActive,
            onTap: onFilters,
          ),
          const SizedBox(width: 10),
          CircleIconButton(
            icon: Icons.notifications_rounded,
            showDot: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        itemCount: MockData.exploreFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = MockData.exploreFilters.keys.elementAt(index);
          return PillChip.filter(
            label: label,
            selected: label == selected,
            onTap: () => onChanged(label),
          );
        },
      ),
    );
  }
}
