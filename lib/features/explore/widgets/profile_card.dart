import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/pill_chip.dart';
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PhotoIndicator(count: photoCount, active: activePhoto),
              const SizedBox(height: 12),
              _KindBadge(kind: profile.kind),
              const Expanded(
                child: Center(
                  // En pantallas bajas el marcador se encoge en vez de
                  // apretujar el bloque de información.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: _PhotoPlaceholder(),
                  ),
                ),
              ),
              _ProfileInfo(profile: profile),
            ],
          ),
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

class _KindBadge extends StatelessWidget {
  const _KindBadge({required this.kind});

  final ProfileKind kind;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            kind.label,
            style: AppTextStyles.chip.copyWith(fontSize: 12.5),
          ),
        ],
      ),
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
