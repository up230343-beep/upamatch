import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_strip.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/mock/mock_data.dart';
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

  String _filter = MockData.exploreFilters.first;

  @override
  Widget build(BuildContext context) {
    final profile = MockData.profiles.first;

    return Column(
      children: [
        const _ExploreHeader(),
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
                            child: ProfileCard(profile: profile),
                          ),
                        ),
                        SwipeActions(
                          // TODO(backend): enviar la decisión al API.
                          onSkip: () {},
                          onLike: () {},
                          onSuperLike: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AvatarStrip(
                      title: 'Nuevos cerca de ti',
                      profiles: MockData.nearby,
                      onAction: () {},
                      onTapProfile: (_) {},
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

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader();

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
          CircleIconButton(icon: Icons.tune_rounded, onTap: () {}),
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
          final label = MockData.exploreFilters[index];
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
