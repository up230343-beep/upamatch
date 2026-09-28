import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/like.dart';
import '../../data/models/profile.dart';
import '../../data/models/swipe_decision.dart';
import '../../routes/app_routes.dart';
import '../match/match_dialog.dart';

/// Pestaña "Likes": quienes dieron like a tu perfil.
///
/// Tocar una tarjeta abre su perfil; si le das like de vuelta, es match.
///
/// TODO(backend): listar los likes reales.
class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  /// Likes que ya respondiste (match o pasar) y salen de la lista.
  final Set<String> _answered = {};

  List<({Like like, Profile profile})> get _likes => [
    for (final like in MockData.likesReceived)
      if (!_answered.contains(like.profileId))
        if (MockData.profileById(like.profileId) case final profile?)
          (like: like, profile: profile),
  ];

  Future<void> _open(Profile profile) async {
    final decision = await Navigator.of(context).pushNamed(
      AppRoutes.profileDetail,
      arguments: profile,
    );
    if (decision is! SwipeDecision || !mounted) return;
    setState(() => _answered.add(profile.id));
    await sendDecision(context, profile, decision);
  }

  @override
  Widget build(BuildContext context) {
    final likes = _likes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Likes',
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.title,
          ),
          if (likes.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              likes.length == 1
                  ? 'A 1 perfil le gustas'
                  : 'A ${likes.length} perfiles les gustas',
              style: AppTextStyles.bodyMuted,
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: likes.isEmpty
                ? const _EmptyLikes()
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                    itemCount: likes.length,
                    itemBuilder: (context, index) => _LikeCard(
                      like: likes[index].like,
                      profile: likes[index].profile,
                      onTap: () => _open(likes[index].profile),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _LikeCard extends StatelessWidget {
  const _LikeCard({
    required this.like,
    required this.profile,
    required this.onTap,
  });

  final Like like;
  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(gradient: AppColors.cardGradient),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        like.time,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (like.isSuperLike)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: AppColors.star,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Super',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: AvatarCircle(
                      size: 72,
                      photoUrl: profile.photoUrl,
                      showRing: false,
                    ),
                  ),
                ),
                Text(
                  profile.headline,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.kind.label} · ${profile.breed}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyLikes extends StatelessWidget {
  const _EmptyLikes();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 92,
          height: 92,
          decoration: const BoxDecoration(
            color: AppColors.surfaceMuted,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            size: 40,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Aún no hay likes nuevos',
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 6),
        const Text(
          'Cuando alguien dé like a tu perfil aparecerá aquí.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
        ),
      ],
    );
  }
}
