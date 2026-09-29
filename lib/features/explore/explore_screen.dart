import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/sesion.dart';
import '../../data/api/upamatch_service.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/profile.dart';
import '../match/match_dialog.dart';
import 'widgets/profile_card.dart';
import 'widgets/swipe_actions.dart';

/// Buscar match: se ve una mascota a la vez y se le da "sí" o "no".
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const double _actionsOverlap = 30;

  String _filtro = MockData.exploreFilters.first;

  List<Profile> _perfiles = [];
  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final perfiles = await UpaMatchService.siguientes(Sesion.usuarioId!);
      if (!mounted) return;
      setState(() {
        _perfiles = perfiles;
        _cargando = false;
      });
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e is ApiException
            ? e.mensaje
            : 'No se pudo conectar con el servidor.';
        _cargando = false;
      });
    }
  }

  /// Las mascotas que quedan según el filtro de arriba.
  List<Profile> get _visibles {
    if (_filtro == 'Perros') {
      return _perfiles.where((p) => p.kind == ProfileKind.perro).toList();
    }
    if (_filtro == 'Gatos') {
      return _perfiles.where((p) => p.kind == ProfileKind.gato).toList();
    }
    if (_filtro == 'Otros') {
      return _perfiles.where((p) => p.kind == ProfileKind.otro).toList();
    }
    return _perfiles;
  }

  /// Guarda el "sí" o el "no" y pasa a la siguiente mascota.
  Future<void> _decidir(Profile perfil, bool esSi) async {
    setState(() => _guardando = true);

    try {
      final resultado = await UpaMatchService.decidir(
        usuarioId: Sesion.usuarioId!,
        otroId: perfil.id,
        esSi: esSi,
      );

      if (!mounted) return;

      // Fuera de la lista: ya se calificó.
      setState(() => _perfiles.removeWhere((p) => p.id == perfil.id));

      if (resultado.huboMatch && resultado.perfil != null) {
        await mostrarMatch(context, resultado.perfil!);
      }
    } on Object catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e is ApiException ? e.mensaje : 'No se pudo guardar tu respuesta.',
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ExploreHeader(),
        const SizedBox(height: 12),
        _FilterBar(
          selected: _filtro,
          onChanged: (valor) => setState(() => _filtro = valor),
        ),
        const SizedBox(height: 14),
        Expanded(child: _contenido()),
      ],
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _Aviso(
        icono: Icons.wifi_off_rounded,
        titulo: 'No se pudo conectar',
        texto: _error!,
        onReintentar: _cargar,
      );
    }

    final visibles = _visibles;

    if (visibles.isEmpty) {
      return _Aviso(
        icono: Icons.pets_rounded,
        titulo: 'Ya viste todas por ahora',
        texto: _perfiles.isEmpty
            ? 'Cuando se registren más mascotas aparecerán aquí.'
            : 'No hay mascotas de ese tipo. Prueba con otro filtro.',
        onReintentar: _cargar,
      );
    }

    final perfil = visibles.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        final alturaTarjeta =
            (constraints.maxHeight - _actionsOverlap - 24).clamp(300.0, 520.0);

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
                      height: alturaTarjeta,
                      child: ProfileCard(profile: perfil),
                    ),
                  ),
                  SwipeActions(
                    onSkip: _guardando ? null : () => _decidir(perfil, false),
                    onLike: _guardando ? null : () => _decidir(perfil, true),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Quedan ${visibles.length} por ver',
                style: AppTextStyles.caption,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

/// Mensaje grande del centro: sin conexión o sin mascotas por ver.
class _Aviso extends StatelessWidget {
  const _Aviso({
    required this.icono,
    required this.titulo,
    required this.texto,
    required this.onReintentar,
  });

  final IconData icono;
  final String titulo;
  final String texto;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
          Text(titulo, style: AppTextStyles.sectionTitle),
          const SizedBox(height: 6),
          Text(texto, textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
          const SizedBox(height: 12),
          TextButton(onPressed: onReintentar, child: const Text('Actualizar')),
        ],
      ),
    );
  }
}

class _ExploreHeader extends StatelessWidget {
  const _ExploreHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Row(
        children: [
          BrandLogo(size: 34),
          SizedBox(width: 10),
          Flexible(
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
          final etiqueta = MockData.exploreFilters[index];
          return PillChip.filter(
            label: etiqueta,
            selected: etiqueta == selected,
            onTap: () => onChanged(etiqueta),
          );
        },
      ),
    );
  }
}
