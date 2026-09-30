import 'package:flutter/material.dart';

import '../../core/abrir_instagram.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/kind_badge.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/match_service.dart';
import '../../data/models/solicitud.dart';
import '../../data/models/swipe_decision.dart';

/// Perfil completo de una solicitud: fotos, nombre, edad, raza, ciudad,
/// descripción, intereses e Instagram.
///
/// Se abre al tocar una solicitud:
/// `Navigator.pushNamed(context, AppRoutes.solicitudDetalle, arguments: solicitud)`.
///
/// - **Pendiente**: sin Instagram (la API no lo manda) y con los botones
///   "No" / "Sí". Devuelve la [SwipeDecision] elegida para que la pantalla de
///   solicitudes la guarde.
/// - **Aceptada**: con el link de Instagram y sin botones.
///
/// Pinta al momento lo que ya trae la lista y luego lo refresca desde la API
/// (`GET /api/match/solicitudes/{id}`) y pide sus fotos a la API de fotos.
class SolicitudDetalleScreen extends StatefulWidget {
  const SolicitudDetalleScreen({
    super.key,
    required this.solicitud,
    this.refrescar = true,
  });

  final Solicitud solicitud;

  /// `false` para enseñarla tal cual, sin pedir nada a las APIs.
  final bool refrescar;

  @override
  State<SolicitudDetalleScreen> createState() => _SolicitudDetalleScreenState();
}

class _SolicitudDetalleScreenState extends State<SolicitudDetalleScreen> {
  late Solicitud _solicitud = widget.solicitud;

  /// Direcciones de sus fotos, empezando por la principal. Mientras llega la
  /// lista se intenta con la principal.
  late List<String> _fotos = [widget.solicitud.fotoUrl];

  /// Mensaje si la solicitud ya no existe (por ejemplo, se borró la cuenta).
  String? _aviso;

  @override
  void initState() {
    super.initState();
    if (widget.refrescar) {
      _refrescarPerfil();
      _cargarFotos();
    }
  }

  Future<void> _refrescarPerfil() async {
    try {
      final solicitud = await MatchService.solicitud(_solicitud.usuarioId);
      if (mounted) setState(() => _solicitud = solicitud);
    } on ApiException catch (e) {
      // Se queda con lo que traía la lista; solo se avisa si ya no existe.
      if (mounted && e.mensaje.contains('ya no existe')) {
        setState(() => _aviso = e.mensaje);
      }
    }
  }

  Future<void> _cargarFotos() async {
    try {
      final fotos = await FotosService.listar(_solicitud.usuarioId);
      if (mounted && fotos.isNotEmpty) {
        setState(() => _fotos = [for (final f in fotos) f.url]);
      }
    } on Object {
      // Sin la API de fotos se queda el marcador.
    }
  }

  void _decidir(SwipeDecision decision) => Navigator.of(context).pop(decision);

  @override
  Widget build(BuildContext context) {
    final solicitud = _solicitud;

    return Scaffold(
      body: Column(
        children: [
          const MockStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                4,
                AppTheme.pagePadding,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Galeria(fotos: _fotos, solicitud: solicitud),
                  const SizedBox(height: 20),
                  _Encabezado(solicitud: solicitud),
                  if (_aviso != null) ...[
                    const SizedBox(height: 12),
                    Text(_aviso!, style: AppTextStyles.bodyMuted),
                  ],
                  const SizedBox(height: 22),
                  const Text('Sobre mí', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 10),
                  _Tarjeta(
                    child: Text(
                      solicitud.descripcion.isEmpty
                          ? 'Todavía no escribe una descripción.'
                          : solicitud.descripcion,
                      style: solicitud.descripcion.isEmpty
                          ? AppTextStyles.bodyMuted
                          : AppTextStyles.body.copyWith(height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text('Intereses', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 10),
                  if (solicitud.intereses.isEmpty)
                    const Text(
                      'Todavía no elige intereses.',
                      style: AppTextStyles.bodyMuted,
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final interes in solicitud.intereses)
                          PillChip.choice(label: interes, selected: true),
                      ],
                    ),
                  const SizedBox(height: 22),
                  const Text('Instagram', style: AppTextStyles.sectionTitle),
                  const SizedBox(height: 10),
                  _InstagramSeccion(solicitud: solicitud),
                ],
              ),
            ),
          ),
          if (!solicitud.aceptada && _aviso == null)
            _BotonesRespuesta(
              nombre: solicitud.nombre,
              onNo: () => _decidir(SwipeDecision.skip),
              onSi: () => _decidir(SwipeDecision.like),
            ),
          const HomeIndicator(),
        ],
      ),
    );
  }
}

/// Fotos deslizables con las barritas arriba, el botón de regresar y el tipo.
class _Galeria extends StatefulWidget {
  const _Galeria({required this.fotos, required this.solicitud});

  final List<String> fotos;
  final Solicitud solicitud;

  @override
  State<_Galeria> createState() => _GaleriaState();
}

class _GaleriaState extends State<_Galeria> {
  int _actual = 0;

  @override
  void didUpdateWidget(covariant _Galeria oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_actual >= widget.fotos.length) _actual = 0;
  }

  @override
  Widget build(BuildContext context) {
    final fotos = widget.fotos;

    return Container(
      height: 380,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Center(child: _MarcadorFoto()),
          PageView.builder(
            itemCount: fotos.length,
            onPageChanged: (i) => setState(() => _actual = i),
            itemBuilder: (context, i) => Image.network(
              fotos[i],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => const SizedBox.shrink(),
            ),
          ),
          // Sombra arriba para que se vean los botones aunque la foto sea clara.
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x59000000), Colors.transparent],
                  stops: [0.0, 0.35],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                if (fotos.length > 1) ...[
                  Row(
                    children: [
                      for (var i = 0; i < fotos.length; i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: Container(
                            height: 3.5,
                            decoration: BoxDecoration(
                              color: i == _actual
                                  ? const Color(0xE6FFFFFF)
                                  : const Color(0x59FFFFFF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                    KindBadge(kind: widget.solicitud.tipo),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MarcadorFoto extends StatelessWidget {
  const _MarcadorFoto();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.image_outlined,
          size: 46,
          color: AppColors.textOnDarkMuted,
        ),
        const SizedBox(height: 10),
        Text(
          'Todavía no tiene fotos',
          style: AppTextStyles.bodyMuted.copyWith(
            color: AppColors.textOnDarkMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Nombre, edad, raza, ciudad y en qué va la solicitud.
class _Encabezado extends StatelessWidget {
  const _Encabezado({required this.solicitud});

  final Solicitud solicitud;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                solicitud.titulo,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.title,
              ),
            ),
            const SizedBox(width: 10),
            _Estado(solicitud: solicitud),
          ],
        ),
        const SizedBox(height: 8),
        if (solicitud.raza.isNotEmpty)
          _Dato(icono: Icons.pets_rounded, texto: solicitud.raza),
        if (solicitud.ciudad.isNotEmpty) ...[
          const SizedBox(height: 4),
          _Dato(icono: Icons.place_rounded, texto: solicitud.ciudad),
        ],
        const SizedBox(height: 4),
        _Dato(
          icono: Icons.cake_rounded,
          texto: solicitud.edad == 1 ? '1 año' : '${solicitud.edad} años',
        ),
      ],
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.icono, required this.texto});

  final IconData icono;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            texto,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMuted,
          ),
        ),
      ],
    );
  }
}

/// Píldora "Pendiente" / "Match".
class _Estado extends StatelessWidget {
  const _Estado({required this.solicitud});

  final Solicitud solicitud;

  @override
  Widget build(BuildContext context) {
    final aceptada = solicitud.aceptada;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: aceptada ? AppColors.primary : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            aceptada ? Icons.favorite_rounded : Icons.schedule_rounded,
            size: 13,
            color: aceptada ? AppColors.textOnDark : AppColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            aceptada ? 'Match' : 'Pendiente',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: aceptada ? AppColors.textOnDark : AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  const _Tarjeta({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// Con match: su @ y el botón para abrirlo. Sin match: candado (la API ni
/// siquiera mandó el link).
class _InstagramSeccion extends StatelessWidget {
  const _InstagramSeccion({required this.solicitud});

  final Solicitud solicitud;

  @override
  Widget build(BuildContext context) {
    final link = solicitud.instagram;

    if (link == null) {
      return const _Tarjeta(
        child: Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.textMuted),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Su Instagram aparece cuando los dos se den "sí".',
                style: AppTextStyles.bodyMuted,
              ),
            ),
          ],
        ),
      );
    }

    return _Tarjeta(
      child: Row(
        children: [
          const Icon(Icons.camera_alt_outlined, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              solicitud.instagramUsuario ?? '',
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => abrirInstagram(context, link),
            child: const Text('Abrir', style: AppTextStyles.link),
          ),
        ],
      ),
    );
  }
}

/// "No" y "Sí" para contestar una solicitud pendiente.
class _BotonesRespuesta extends StatelessWidget {
  const _BotonesRespuesta({
    required this.nombre,
    required this.onNo,
    required this.onSi,
  });

  final String nombre;
  final VoidCallback onNo;
  final VoidCallback onSi;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        12,
        AppTheme.pagePadding,
        12,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'A $nombre le gustas. ¿Tú qué dices?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: onNo,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.borderStrong),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      'No',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GradientButton(label: 'Sí', onPressed: onSi),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
