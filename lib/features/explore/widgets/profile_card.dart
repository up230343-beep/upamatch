import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/kind_badge.dart';
import '../../../core/widgets/pill_chip.dart';
import '../../../data/api/fotos_service.dart';
import '../../../data/models/profile.dart';

/// Tarjeta grande de perfil de la pantalla "Explorar".
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    this.photoCount = 4,
    this.activePhoto = 0,
  });

  final Profile profile;
  final int photoCount;
  final int activePhoto;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E6C34CC),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Debajo de todo queda el marcador "Pon aquí la foto": se ve
            // cuando el perfil todavía no tiene foto subida.
            const Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _PhotoPlaceholder(),
              ),
            ),
            // La foto del perfil, tapando el marcador. Si el usuario no tiene
            // foto la API responde 404 y esto no pinta nada.
            Image.network(
              FotosService.urlPrincipal(profile.id),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
            // Sombra arriba y abajo para que el texto se lea aunque la foto
            // sea clara. El centro se deja limpio para que se vea la foto.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x59000000),
                    Colors.transparent,
                    Color(0xD9000000),
                  ],
                  stops: [0.0, 0.3, 0.92],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PhotoIndicator(count: photoCount, active: activePhoto),
                  const SizedBox(height: 12),
                  KindBadge(kind: profile.kind),
                  const Spacer(),
                  _ProfileInfo(profile: profile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoIndicator extends StatelessWidget {
  const _PhotoIndicator({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 3.5,
              decoration: BoxDecoration(
                color: i == active
                    ? const Color(0xE6FFFFFF)
                    : const Color(0x59FFFFFF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Marcador de foto. El mockup no trae imagen: muestra el hueco.
///
/// TODO(backend): cuando `profile.photoUrl` llegue del API, pintar aquí un
/// `Image.network(profile.photoUrl!)` con `BoxFit.cover`.
class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.image_outlined,
          size: 46,
          color: Color(0xCCFFFFFF),
        ),
        const SizedBox(height: 10),
        Text(
          'Pon aquí la foto del perfil',
          style: AppTextStyles.bodyMuted.copyWith(
            color: const Color(0xE6FFFFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileInfo extends StatelessWidget {
  const _ProfileInfo({required this.profile});

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
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: AppColors.textOnDark,
                ),
              ),
            ),
            if (profile.isVerified) ...[
              const SizedBox(width: 8),
              Container(
                width: 19,
                height: 19,
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
            const Icon(
              Icons.place_rounded,
              size: 15,
              color: Color(0xE6FFFFFF),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                profile.subtitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xF2FFFFFF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text('SOBRE MÍ', style: AppTextStyles.overline),
        const SizedBox(height: 5),
        Text(
          profile.about,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            height: 1.35,
            color: Color(0xF2FFFFFF),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final tag in profile.tags) PillChip.glass(label: tag),
          ],
        ),
      ],
    );
  }
}
