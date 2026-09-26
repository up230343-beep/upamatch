import 'package:flutter/material.dart';

import '../../data/models/profile.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme.dart';
import 'avatar_circle.dart';

/// Sección con un título, un enlace a la derecha y una fila horizontal de
/// avatares. La usan "Nuevos cerca de ti" (Explorar) y "Nuevos matches"
/// (Chats).
class AvatarStrip extends StatelessWidget {
  const AvatarStrip({
    super.key,
    required this.title,
    required this.profiles,
    this.actionLabel = 'Ver todos',
    this.onAction,
    this.onTapProfile,
    this.horizontalPadding = AppTheme.pagePadding,
  });

  final String title;
  final List<NearbyProfile> profiles;
  final String actionLabel;
  final VoidCallback? onAction;
  final ValueChanged<NearbyProfile>? onTapProfile;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sectionTitle,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onAction,
                child: Text(actionLabel, style: AppTextStyles.link),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: profiles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return GestureDetector(
                onTap: onTapProfile == null ? null : () => onTapProfile!(profile),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AvatarCircle(photoUrl: profile.photoUrl),
                    const SizedBox(height: 7),
                    SizedBox(
                      width: 58,
                      child: Text(
                        profile.name,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.chip.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
