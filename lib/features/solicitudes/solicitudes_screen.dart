import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/sesion.dart';
import '../../data/api/upamatch_service.dart';
import '../../data/models/solicitud.dart';
import '../profile_detail/profile_detail_screen.dart';

/// Solicitudes de match.
///
/// - **Pendientes**: te dieron "sí" y todavía no contestas.
/// - **Aceptadas**: ya son match, y ahí se puede ver el Instagram.
class SolicitudesScreen extends StatefulWidget {
  const SolicitudesScreen({super.key});

  @override
  State<SolicitudesScreen> createState() => _SolicitudesScreenState();
}

class _SolicitudesScreenState extends State<SolicitudesScreen> {
  Solicitudes? _solicitudes;
  bool _cargando = true;
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
      final datos = await UpaMatchService.solicitudes(Sesion.usuarioId!);
      if (!mounted) return;
      setState(() {
        _solicitudes = datos;
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

  /// Abre el perfil completo. Al volver se recarga, por si hubo match.
  Future<void> _abrir(Solicitud solicitud) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProfileDetailScreen(
          perfilId: solicitud.perfil.id,
          esMatch: solicitud.aceptada,
        ),
      ),
    );

    if (mounted) await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Flexible(
                child: Text(
                  'Solicitudes',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                onPressed: _cargando ? null : _cargar,
              ),
            ],
          ),
          Expanded(child: _contenido()),
        ],
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _Vacio(
        icono: Icons.wifi_off_rounded,
        titulo: 'No se pudo conectar',
        texto: _error!,
      );
    }

    final datos = _solicitudes!;

    if (datos.vacio) {
      return const _Vacio(
        icono: Icons.favorite_rounded,
        titulo: 'Todavía no hay solicitudes',
        texto: 'Cuando alguien le dé "sí" a tu mascota aparecerá aquí.',
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        if (datos.pendientes.isNotEmpty) ...[
          _Encabezado(
            titulo: 'Pendientes',
            cantidad: datos.pendientes.length,
            nota: 'Les gustaste. Ábrelas para decidir.',
          ),
          for (final s in datos.pendientes)
            _Fila(solicitud: s, onTap: () => _abrir(s)),
          const SizedBox(height: 22),
        ],
        if (datos.aceptadas.isNotEmpty) ...[
          _Encabezado(
            titulo: 'Match',
            cantidad: datos.aceptadas.length,
            nota: 'Ábrelas para ver su Instagram.',
          ),
          for (final s in datos.aceptadas)
            _Fila(solicitud: s, onTap: () => _abrir(s)),
        ],
      ],
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.titulo,
    required this.cantidad,
    required this.nota,
  });

  final String titulo;
  final int cantidad;
  final String nota;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('$titulo ($cantidad)', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 2),
          Text(nota, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Un renglón de la lista: la foto, el nombre y si ya es match.
class _Fila extends StatelessWidget {
  const _Fila({required this.solicitud, required this.onTap});

  final Solicitud solicitud;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final perfil = solicitud.perfil;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                AvatarCircle(
                  size: 52,
                  photoUrl: FotosService.urlPrincipal(perfil.id),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        perfil.headline,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        solicitud.aceptada
                            ? '${perfil.breed} · ya son match'
                            : '${perfil.breed} · te dio un sí',
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                if (solicitud.aceptada)
                  const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 20,
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                    size: 22,
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
  });

  final IconData icono;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Column(
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
      ],
    );
  }
}
