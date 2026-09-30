import 'package:flutter/material.dart';

import '../../core/abrir_instagram.dart';
import '../../core/instagram.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/avatar_circle.dart';
<<<<<<< HEAD
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/instagram_link.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/sesion.dart';
import '../../data/models/profile.dart';

/// Aviso de "¡Es un match!".
///
/// Sale encima de todo cuando le das "sí" a una mascota que ya te había dado
/// "sí" a ti. Aquí es donde por fin aparece el Instagram: es la forma de
/// contactarse, porque la app no tiene mensajes.
Future<void> mostrarMatch(BuildContext context, Profile perfil) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => _MatchDialog(perfil: perfil),
  );
}

class _MatchDialog extends StatelessWidget {
  const _MatchDialog({required this.perfil});

  final Profile perfil;
=======
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
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6

  @override
  Widget build(BuildContext context) {
    final miId = '${Sesion.usuarioId}';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¡Es un match!',
              style: AppTextStyles.title.copyWith(
                color: AppColors.textOnDark,
                fontSize: 26,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'A ti y a ${perfil.name} se gustaron',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textOnDarkMuted,
              ),
            ),
            const SizedBox(height: 22),
            // Las dos mascotas, una junto a la otra.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AvatarCircle(
                  size: 84,
                  photoUrl: FotosService.urlPrincipal(miId),
                  showRing: false,
                ),
                const SizedBox(width: 14),
                const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.textOnDark,
                  size: 26,
                ),
<<<<<<< HEAD
                const SizedBox(width: 14),
                AvatarCircle(
                  size: 84,
                  photoUrl: FotosService.urlPrincipal(perfil.id),
                  showRing: false,
=======
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
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
                ),
              ],
            ),
            const SizedBox(height: 24),
            _Instagram(instagram: perfil.instagram),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Seguir buscando',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// El link de Instagram de la otra mascota, que es como se van a contactar.
class _Instagram extends StatelessWidget {
  const _Instagram({required this.instagram});

  final String? instagram;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.alternate_email_rounded,
                size: 17,
                color: AppColors.textOnDark,
              ),
              SizedBox(width: 6),
              Text(
                'Contáctense por Instagram',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textOnDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InstagramLink(instagram: instagram, sobreFondoOscuro: true),
        ],
      ),
    );
  }
}
