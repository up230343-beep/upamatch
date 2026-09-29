import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/instagram_link.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/sesion.dart';
import '../../data/api/upamatch_service.dart';
import '../../data/models/foto.dart';
import '../../data/models/profile.dart';
import '../match/match_dialog.dart';

/// El perfil completo de otra mascota.
///
/// Se abre desde las solicitudes. Si ya son match se ve su Instagram; si la
/// solicitud está pendiente, abajo salen los botones para decidir.
class ProfileDetailScreen extends StatefulWidget {
  const ProfileDetailScreen({
    super.key,
    required this.perfilId,
    required this.esMatch,
  });

  final String perfilId;
  final bool esMatch;

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  Profile? _perfil;
  List<Foto> _fotos = [];
  bool _cargando = true;
  bool _guardando = false;
  String? _error;
  late bool _esMatch = widget.esMatch;

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
      final perfil = await UpaMatchService.perfilDe(
        Sesion.usuarioId!,
        widget.perfilId,
      );

      // Las fotos van por su lado, a la API de Azure.
      final fotos = await FotosService.listar(widget.perfilId);

      if (!mounted) return;
      setState(() {
        _perfil = perfil;
        _fotos = fotos;
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

  /// Contesta la solicitud pendiente.
  Future<void> _responder(bool esSi) async {
    setState(() => _guardando = true);

    try {
      final resultado = await UpaMatchService.decidir(
        usuarioId: Sesion.usuarioId!,
        otroId: widget.perfilId,
        esSi: esSi,
      );

      if (!mounted) return;

      if (resultado.huboMatch && resultado.perfil != null) {
        setState(() => _esMatch = true);
        await mostrarMatch(context, resultado.perfil!);
        await _cargar();
      } else {
        Navigator.of(context).pop();
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                8,
                AppTheme.pagePadding,
                8,
              ),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: Icons.chevron_left_rounded,
                    size: 40,
                    iconSize: 24,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      _perfil?.name ?? 'Perfil',
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null || _perfil == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted),
              const SizedBox(height: 10),
              Text(
                _error ?? 'No se pudo cargar el perfil.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
              const SizedBox(height: 10),
              TextButton(onPressed: _cargar, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    final perfil = _perfil!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        0,
        AppTheme.pagePadding,
        20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Fotos(perfilId: perfil.id, fotos: _fotos),
          const SizedBox(height: 18),
          Text(perfil.headline, style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(perfil.subtitle, style: AppTextStyles.bodyMuted),
          if (perfil.about.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Sobre mí', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 8),
            Text(
              perfil.about,
              style: AppTextStyles.body.copyWith(height: 1.45),
            ),
          ],
          if (perfil.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text('Intereses', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in perfil.tags)
                    PillChip.choice(label: tag, selected: true),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          if (_esMatch)
            _Instagram(instagram: perfil.instagram)
          else
            _Decidir(
              nombre: perfil.name,
              guardando: _guardando,
              onSi: () => _responder(true),
              onNo: () => _responder(false),
            ),
        ],
      ),
    );
  }
}

/// Las fotos de la mascota, una al lado de otra.
class _Fotos extends StatelessWidget {
  const _Fotos({required this.perfilId, required this.fotos});

  final String perfilId;
  final List<Foto> fotos;

  @override
  Widget build(BuildContext context) {
    if (fotos.isEmpty) {
      return Container(
        height: 260,
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 46,
            color: AppColors.textOnDarkMuted,
          ),
        ),
      );
    }

    return SizedBox(
      height: 260,
      child: PageView(
        children: [
          for (final foto in fotos)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  foto.url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stack) => const ColoredBox(
                    color: AppColors.surfaceMuted,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// El Instagram, que solo aparece cuando ya son match.
class _Instagram extends StatelessWidget {
  const _Instagram({required this.instagram});

  final String? instagram;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.alternate_email_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              SizedBox(width: 6),
              Text('Instagram', style: AppTextStyles.sectionTitle),
            ],
          ),
          const SizedBox(height: 8),
          InstagramLink(instagram: instagram),
          const SizedBox(height: 4),
          const Text(
            'Tócalo para abrir su perfil de Instagram.',
            textAlign: TextAlign.center,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

/// Los botones de sí y no para contestar una solicitud pendiente.
class _Decidir extends StatelessWidget {
  const _Decidir({
    required this.nombre,
    required this.guardando,
    required this.onSi,
    required this.onNo,
  });

  final String nombre;
  final bool guardando;
  final VoidCallback onSi;
  final VoidCallback onNo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$nombre te dio un sí',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMuted,
        ),
        const SizedBox(height: 12),
        GradientButton(
          label: guardando ? 'Guardando...' : 'También me gusta',
          onPressed: guardando ? null : onSi,
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: guardando ? null : onNo,
          child: Text(
            'No, gracias',
            style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
