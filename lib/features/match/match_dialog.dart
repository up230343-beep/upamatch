import 'package:flutter/material.dart';

import '../../core/abrir_instagram.dart';
import '../../core/instagram.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/api/api_config.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/match_service.dart';
import '../../data/mis_solicitudes.dart';
import '../../data/models/profile.dart';
import '../../data/models/swipe_decision.dart';

/// Guarda el "sí" (like / super like) o el "no" (pasar) en la API. Si con
/// ese "sí" se completa el match, le avisa a quien lo acaba de completar con
/// el diálogo de match (con el Instagram que manda la API).
///
/// Devuelve `false` si no se pudo guardar (ya enseñó el error), para que la
/// pantalla regrese el perfil.
Future<bool> sendDecision(
  BuildContext context,
  Profile profile,
  SwipeDecision decision,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final ResultadoCalificacion resultado;
  try {
    resultado = await MatchService.calificar(profile.id, decision);
  } on ApiException catch (e) {
    messenger?.showSnackBar(SnackBar(content: Text(e.mensaje)));
    return false;
  }

  final perfil = resultado.perfil;
  if (resultado.match && perfil != null) {
    MisSolicitudes.instancia.aceptada(perfil);
    if (context.mounted) await showMatchDialog(context, perfil.toProfile());
  } else {
    // Si era una solicitud pendiente y le diste "no", sale de la lista.
    MisSolicitudes.instancia.contestada(profile.id);
  }
  return true;
}

/// 07 · ¡Es un match!
///
/// Se muestra encima de todo cuando das like a alguien que ya te había dado
/// like. No hay chat en la app: "Abrir su Instagram" abre el link de su
/// perfil y la plática sigue por ahí.
Future<void> showMatchDialog(BuildContext context, Profile profile) {
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
      onInstagram: () => abrirInstagram(dialogContext, profile.instagram),
      onKeepExploring: () => Navigator.of(dialogContext).pop(),
    ),
  );
}

class _MatchView extends StatelessWidget {
  const _MatchView({
    required this.profile,
    required this.onInstagram,
    required this.onKeepExploring,
  });

  final Profile profile;
  final VoidCallback onInstagram;
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
                  'Escríbele por Instagram: '
                  '${Instagram.usuario(profile.instagram)}',
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
                            photoUrl: FotosService.urlPrincipal(
                              ApiConfig.usuarioId,
                            ),
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
                      onTap: onInstagram,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Abrir su Instagram',
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.button.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
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
