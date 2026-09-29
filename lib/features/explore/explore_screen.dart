import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_strip.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/api/fotos_service.dart' show ApiException;
import '../../data/api/match_service.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/explore_filters.dart';
import '../../data/models/profile.dart';
import '../../data/models/swipe_decision.dart';
import '../../routes/app_routes.dart';
import '../match/match_dialog.dart';
import 'widgets/filters_sheet.dart';
import 'widgets/profile_card.dart';
import 'widgets/swipe_actions.dart';

/// 03 · Explorar perfiles (buscar match)
///
/// Los perfiles salen de la API: solo los que todavía no calificaste y nunca
/// el tuyo. Cada "sí" o "no" se guarda en la API y el perfil ya no vuelve.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const double _actionsOverlap = 30;

  String _filter = MockData.exploreFilters.keys.first;
  ExploreFilters _filters = const ExploreFilters();

  /// Perfiles por ver, en orden. El primero es la tarjeta.
  List<Profile> _perfiles = const [];
  bool _cargando = true;
  String? _error;

  /// Cuenta las cargas para ignorar respuestas viejas (si cambias de filtro
  /// mientras carga).
  int _carga = 0;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final carga = ++_carga;
    setState(() {
      _perfiles = const [];
      _cargando = true;
      _error = null;
    });

    try {
      final perfiles = await MatchService.perfiles(
        tipo: MockData.exploreFilters[_filter],
        edadMin: _filters.minAge == ExploreFilters.ageLimitMin
            ? null
            : _filters.minAge,
        edadMax: _filters.maxAge == ExploreFilters.ageLimitMax
            ? null
            : _filters.maxAge,
      );
      if (!mounted || carga != _carga) return;
      setState(() {
        _perfiles = perfiles;
        _cargando = false;
      });
    } on ApiException catch (e) {
      if (!mounted || carga != _carga) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  Future<void> _decide(Profile profile, SwipeDecision decision) async {
    // Se pasa al siguiente de inmediato; si la API falla, regresa.
    setState(() => _perfiles = [
          for (final p in _perfiles)
            if (p.id != profile.id) p,
        ]);

    final guardado = await sendDecision(context, profile, decision);
    if (!mounted) return;

    if (!guardado) {
      setState(() => _perfiles = [profile, ..._perfiles]);
    } else if (_perfiles.isEmpty && !_cargando) {
      // Se acabó esta tanda: se pide la siguiente. Si ya no hay, se avisa.
      await _cargar();
    }
  }

  Future<void> _openDetail(Profile profile) async {
    final decision = await Navigator.of(context).pushNamed(
      AppRoutes.profileDetail,
      arguments: profile,
    );
    if (decision is SwipeDecision && mounted) {
      await _decide(profile, decision);
    }
  }

  Future<void> _openFilters() async {
    final filters = await showFiltersSheet(context, _filters);
    if (filters != null) {
      setState(() => _filters = filters);
      await _cargar();
    }
  }

  void _cambiarFiltro(String value) {
    if (value == _filter) return;
    setState(() => _filter = value);
    _cargar();
  }

  /// Lo que va en el lugar de la tarjeta.
  Widget _contenido(Profile? profile) {
    if (_cargando) return const _Cargando();
    if (_error != null) {
      return _Aviso(
        icono: Icons.wifi_off_rounded,
        titulo: 'No se pudieron cargar los perfiles',
        texto: _error!,
        accion: 'Reintentar',
        onAccion: _cargar,
      );
    }
    if (profile == null) {
      return _Aviso(
        icono: Icons.pets_rounded,
        titulo: 'Ya no quedan perfiles por ver',
        texto: 'Ya calificaste a todos por aquí. Vuelve más tarde o '
            'cambia los filtros.',
        accion: 'Buscar de nuevo',
        onAccion: _cargar,
      );
    }
    return GestureDetector(
      onTap: () => _openDetail(profile),
      child: ProfileCard(key: ValueKey(profile.id), profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _perfiles.isEmpty ? null : _perfiles.first;
    final siguientes = [
      for (final p in _perfiles.skip(1).take(8))
        NearbyProfile(id: p.id, name: p.name, photoUrl: p.photoUrl),
    ];

    return Column(
      children: [
        _ExploreHeader(
          filtersActive: !_filters.isDefault,
          onFilters: _openFilters,
        ),
        const SizedBox(height: 12),
        _FilterBar(selected: _filter, onChanged: _cambiarFiltro),
        const SizedBox(height: 14),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // La tarjeta ocupa el alto libre, dejando sitio a la fila
              // "Nuevos cerca de ti" y sus separaciones, igual que en el
              // mockup (390 x 844).
              const nearbySectionHeight = 156.0;
              final cardHeight = (constraints.maxHeight -
                      nearbySectionHeight -
                      _actionsOverlap)
                  .clamp(300.0, 460.0);

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomCenter,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppTheme.pagePadding,
                            0,
                            AppTheme.pagePadding,
                            _actionsOverlap,
                          ),
                          child: SizedBox(
                            height: cardHeight,
                            child: _contenido(profile),
                          ),
                        ),
                        if (profile != null)
                          SwipeActions(
                            onSkip: () => _decide(profile, SwipeDecision.skip),
                            onLike: () => _decide(profile, SwipeDecision.like),
                            onSuperLike: () =>
                                _decide(profile, SwipeDecision.superLike),
                          ),
                      ],
                    ),
                    if (siguientes.isNotEmpty) ...[
                      const SizedBox(height: 22),
                      AvatarStrip(
                        title: 'Nuevos cerca de ti',
                        profiles: siguientes,
                        actionLabel: '',
                        onTapProfile: (nearby) {
                          for (final p in _perfiles) {
                            if (p.id == nearby.id) {
                              _openDetail(p);
                              return;
                            }
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
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

class _Cargando extends StatelessWidget {
  const _Cargando();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}

/// Aviso en el lugar de la tarjeta: se acabaron los perfiles o falló la
/// carga.
class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.titulo,
    required this.texto,
    required this.accion,
    required this.onAccion,
  });

  final IconData icono;
  final String titulo;
  final String texto;
  final String accion;
  final VoidCallback onAccion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 36, color: AppColors.primaryLight),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 18),
          TextButton(
            onPressed: onAccion,
            child: Text(accion, style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader({required this.filtersActive, required this.onFilters});

  final bool filtersActive;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Row(
        children: [
          const BrandLogo(size: 34),
          const SizedBox(width: 10),
          const Flexible(
            child: Text(
              'UpaMatch',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          CircleIconButton(
            icon: Icons.tune_rounded,
            showDot: filtersActive,
            onTap: onFilters,
          ),
          const SizedBox(width: 10),
          CircleIconButton(
            icon: Icons.notifications_rounded,
            showDot: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
        itemCount: MockData.exploreFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = MockData.exploreFilters.keys.elementAt(index);
          return PillChip.filter(
            label: label,
            selected: label == selected,
            onTap: () => onChanged(label),
          );
        },
      ),
    );
  }
}
