import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/avatar_circle.dart';
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
                const SizedBox(width: 14),
                AvatarCircle(
                  size: 84,
                  photoUrl: FotosService.urlPrincipal(perfil.id),
                  showRing: false,
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
