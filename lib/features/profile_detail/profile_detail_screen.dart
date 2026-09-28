import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/kind_badge.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/models/profile.dart';
import '../../data/models/swipe_decision.dart';
import '../explore/widgets/swipe_actions.dart';

/// 08 · Detalle de perfil
///
/// Se abre con
/// `Navigator.pushNamed(context, AppRoutes.profileDetail, arguments: profile)`
/// y devuelve la [SwipeDecision] elegida (o `null` si solo se regresa), para
/// que quien la abrió aplique el like / pasar.
class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key, required this.profile});

  final Profile profile;

  static const double _actionsOverlap = 32;

  @override
  Widget build(BuildContext context) {
    void decide(SwipeDecision decision) => Navigator.of(context).pop(decision);

    return Scaffold(
      body: Column(
        children: [
          const MockStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.pagePadding,
                          4,
                          AppTheme.pagePadding,
                          _actionsOverlap,
                        ),
                        child: _PhotoHeader(profile: profile),
                      ),
                      SwipeActions(
                        onSkip: () => decide(SwipeDecision.skip),
                        onLike: () => decide(SwipeDecision.like),
                        onSuperLike: () => decide(SwipeDecision.superLike),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.pagePadding,
                    ),
                    child: _Info(profile: profile),
                  ),
                ],
              ),
            ),
          ),
          const HomeIndicator(),
        ],
      ),
    );
  }
}

class _PhotoHeader extends StatelessWidget {
  const _PhotoHeader({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 360,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleIconButton(
                icon: Icons.arrow_back_rounded,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              const Spacer(),
              KindBadge(kind: profile.kind),
            ],
          ),
          // TODO(backend): galería con las fotos reales (`profile.photoUrl`).
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.image_outlined,
                    size: 46,
                    color: AppColors.textOnDarkMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pon aquí la foto del perfil',
                    style: AppTextStyles.bodyMuted.copyWith(
                      color: AppColors.textOnDarkMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                profile.headline,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title,
              ),
            ),
            if (profile.isVerified) ...[
              const SizedBox(width: 8),
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.verified,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.place_rounded, size: 16, color: AppColors.primary),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                profile.subtitle,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text('Sobre mí', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            profile.about,
            style: AppTextStyles.body.copyWith(height: 1.45),
          ),
        ),
        const SizedBox(height: 22),
        const Text('Intereses', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in profile.tags)
              PillChip.choice(label: tag, selected: true),
          ],
        ),
      ],
    );
  }
}
