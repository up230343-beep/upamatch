import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/conversation.dart';
import '../../data/models/profile.dart';
import '../../data/models/swipe_decision.dart';
import '../../routes/app_routes.dart';

/// Aplica un like / super like / pasar y, si esa persona ya te había dado
/// like, muestra el match.
///
/// TODO(backend): enviar la decisión al API; su respuesta dice si hubo match.
Future<void> sendDecision(
  BuildContext context,
  Profile profile,
  SwipeDecision decision,
) async {
  if (decision == SwipeDecision.skip) return;
  if (MockData.likedYou(profile.id)) {
    await showMatchDialog(context, profile);
  }
}

/// 07 · ¡Es un match!
///
/// Se muestra encima de todo cuando das like a alguien que ya te había dado
/// like. "Enviar mensaje" abre el chat con esa persona.
Future<void> showMatchDialog(BuildContext context, Profile profile) {
  final navigator = Navigator.of(context);

  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.dark.withValues(alpha: 0.4),
    transitionDuration: const Duration(milliseconds: 280),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.92, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        ),
        child: child,
      ),
    ),
    pageBuilder: (dialogContext, _, _) => _MatchView(
      profile: profile,
      onMessage: () {
        Navigator.of(dialogContext).pop();
        navigator.pushNamed(
          AppRoutes.chatDetail,
          arguments: _conversationWith(profile),
        );
      },
      onKeepExploring: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

/// Conversación existente con ese perfil o una nueva, vacía.
///
/// TODO(backend): crear la conversación en el API al hacer match.
Conversation _conversationWith(Profile profile) {
  for (final conversation in MockData.conversations) {
    if (conversation.id == profile.id) return conversation;
  }
  return Conversation(
    id: profile.id,
    name: profile.name,
    lastMessage: '',
    time: 'Ahora',
    photoUrl: profile.photoUrl,
  );
}

class _MatchView extends StatelessWidget {
  const _MatchView({
    required this.profile,
    required this.onMessage,
    required this.onKeepExploring,
  });

  final Profile profile;
  final VoidCallback onMessage;
  final VoidCallback onKeepExploring;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            margin: const EdgeInsets.all(AppTheme.pagePadding),
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSheet + 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite_rounded,
                  size: 34,
                  color: AppColors.textOnDark,
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Es un match!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'A ti y a ${profile.name} se gustaron. '
                  '¡Salúdale!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textOnDarkMuted,
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 110,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.translate(
                        offset: const Offset(-42, 0),
                        child: Transform.rotate(
                          angle: -0.12,
                          child: _MatchAvatar(
                            photoUrl: MockData.currentUser.photoUrl,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(42, 0),
                        child: Transform.rotate(
                          angle: 0.12,
                          child: _MatchAvatar(photoUrl: profile.photoUrl),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: AppColors.surface,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.floatingShadow,
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: Material(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(26),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(26),
                      onTap: onMessage,
                      child: Center(
                        child: Text(
                          'Enviar mensaje',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onKeepExploring,
                  child: const Text(
                    'Seguir explorando',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textOnDark,
                    ),
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

class _MatchAvatar extends StatelessWidget {
  const _MatchAvatar({this.photoUrl});

  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: AvatarCircle(size: 96, photoUrl: photoUrl, showRing: false),
    );
  }
}
