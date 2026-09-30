import 'package:flutter/material.dart';

import '../../core/abrir_instagram.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/mis_solicitudes.dart';
import '../../data/models/solicitud.dart';
import '../../data/models/swipe_decision.dart';
import '../../routes/app_routes.dart';
import '../match/match_dialog.dart';

/// Pestaña "Likes": tus solicitudes, en dos listas.
///
/// - **Pendientes**: te dieron "sí" y no has contestado. Sin Instagram.
/// - **Aceptadas**: ya son match. Con el botón para abrir su Instagram.
///
/// Tocar una abre su perfil completo ([AppRoutes.solicitudDetalle]); en las
/// pendientes ahí se contesta "sí" o "no".
///
/// Los datos salen de la API a través de [MisSolicitudes].
class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  bool _verAceptadas = false;

  Future<void> _abrir(Solicitud solicitud) async {
    final decision = await Navigator.of(context).pushNamed(
      AppRoutes.solicitudDetalle,
      arguments: solicitud,
    );
    if (decision is! SwipeDecision || !mounted) return;

    // Si es "sí", sendDecision enseña el match y la pasa a aceptadas.
    await sendDecision(context, solicitud.toProfile(), decision);
  }

  @override
  Widget build(BuildContext context) {
    final store = MisSolicitudes.instancia;

    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final pendientes = store.pendientes;
        final aceptadas = store.aceptadas;
        final lista = _verAceptadas ? aceptadas : pendientes;

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: store.cargar,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.pagePadding,
                ),
                sliver: SliverList.list(
                  children: [
                    const Text(
                      'Solicitudes',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        PillChip.filter(
                          label: 'Pendientes (${pendientes.length})',
                          selected: !_verAceptadas,
                          onTap: () => setState(() => _verAceptadas = false),
                        ),
                        const SizedBox(width: 8),
                        PillChip.filter(
                          label: 'Aceptadas (${aceptadas.length})',
                          selected: _verAceptadas,
                          onTap: () => setState(() => _verAceptadas = true),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _verAceptadas
                          ? 'Ya son match: escríbeles por Instagram.'
                          : pendientes.length == 1
                              ? 'A 1 perfil le gustas'
                              : 'A ${pendientes.length} perfiles les gustas',
                      style: AppTextStyles.bodyMuted,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              if (lista.isEmpty)
                SliverToBoxAdapter(
                  child: _estadoVacio(store),
                )
              else if (_verAceptadas)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.pagePadding,
                    0,
                    AppTheme.pagePadding,
                    16,
                  ),
                  sliver: SliverList.separated(
                    itemCount: aceptadas.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _MatchTile(
                      solicitud: aceptadas[index],
                      onTap: () => _abrir(aceptadas[index]),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.pagePadding,
                    0,
                    AppTheme.pagePadding,
                    16,
                  ),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: pendientes.length,
                    itemBuilder: (context, index) => _LikeCard(
                      solicitud: pendientes[index],
                      onTap: () => _abrir(pendientes[index]),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _estadoVacio(MisSolicitudes store) {
    if (!store.cargado && store.error == null) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    if (store.error != null) {
      return _Vacio(
        icono: Icons.wifi_off_rounded,
        titulo: 'No se pudieron cargar',
        texto: store.error!,
        accion: 'Reintentar',
        onAccion: store.cargar,
      );
    }
    return _verAceptadas
        ? const _Vacio(
            icono: Icons.favorite_rounded,
            titulo: 'Todavía no tienes matches',
            texto: 'Cuando tú y alguien más se den "sí", aparecerá aquí con su '
                'Instagram.',
          )
        : const _Vacio(
            icono: Icons.favorite_rounded,
            titulo: 'Aún no hay likes nuevos',
            texto: 'Cuando alguien dé like a tu perfil aparecerá aquí.',
          );
  }
}

/// Una solicitud aceptada: foto, nombre, su @ de Instagram y el botón para
/// abrirlo.
class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.solicitud, required this.onTap});

  final Solicitud solicitud;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final link = solicitud.instagram;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              AvatarCircle(size: 48, photoUrl: solicitud.fotoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      solicitud.titulo,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      solicitud.instagramUsuario ?? '',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMuted,
                    ),
                  ],
                ),
              ),
              if (link != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                    onTap: () => abrirInstagram(context, link),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.camera_alt_outlined,
                            size: 17,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Instagram',
                            style: AppTextStyles.link.copyWith(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Una solicitud pendiente (tarjeta morada).
class _LikeCard extends StatelessWidget {
  const _LikeCard({required this.solicitud, required this.onTap});

  final Solicitud solicitud;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final detalle = [
      solicitud.tipo.label,
      if (solicitud.raza.isNotEmpty) solicitud.raza,
    ].join(' · ');

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
                        solicitud.hace,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textOnDarkMuted,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (solicitud.esSuperLike)
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
                      photoUrl: solicitud.fotoUrl,
                      showRing: false,
                    ),
                  ),
                ),
                Text(
                  solicitud.titulo,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textOnDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
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

class _Vacio extends StatelessWidget {
  const _Vacio({
    required this.icono,
    required this.titulo,
    required this.texto,
    this.accion,
    this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String texto;
  final String? accion;
  final VoidCallback? onAccion;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.pagePadding,
        vertical: 24,
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 40, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 18),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle,
          ),
          const SizedBox(height: 6),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          if (accion != null && onAccion != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: onAccion,
              child: Text(accion!, style: AppTextStyles.link),
            ),
          ],
        ],
      ),
    );
  }
}
