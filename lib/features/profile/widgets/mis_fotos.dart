import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/api/api_config.dart';
import '../../../data/api/fotos_service.dart';
import '../../../data/models/foto.dart';

/// Sección "Mis fotos" del perfil: enseña las fotos que hay en la API y deja
/// subir, cambiar y eliminar.
///
/// Solo se pintan las fotos que existen: si el usuario tiene una, se ve una.
/// El botón "+" aparece mientras quede espacio (máximo 5).
class MisFotos extends StatefulWidget {
  const MisFotos({super.key});

  @override
  State<MisFotos> createState() => _MisFotosState();
}

class _MisFotosState extends State<MisFotos> {
  static const String _usuarioId = ApiConfig.usuarioId;

  final _picker = ImagePicker();

  List<Foto> _fotos = [];
  bool _cargando = true;
  bool _ocupado = false;
  String? _error;

  /// Al reemplazar una foto la dirección no cambia, así que el navegador
  /// seguiría enseñando la anterior. Este número se añade al final de la URL
  /// para obligarlo a pedirla de nuevo.
  int _version = 0;

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
      final fotos = await FotosService.listar(_usuarioId);
      if (!mounted) return;
      setState(() {
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

  /// Pide una foto de la galería del teléfono (o del explorador, en web).
  /// Devuelve null si la persona cancela.
  Future<XFile?> _elegirFoto() => _picker.pickImage(
        source: ImageSource.gallery,
        // Se reduce antes de mandarla: la API no acepta más de 10 MB.
        maxWidth: 1600,
        imageQuality: 85,
      );

  Future<void> _agregar() async {
    final archivo = await _elegirFoto();
    if (archivo == null) return;

    await _ejecutar(
      () => FotosService.subir(_usuarioId, archivo),
      'Foto subida',
    );
  }

  Future<void> _cambiar(Foto foto) async {
    final archivo = await _elegirFoto();
    if (archivo == null) return;

    await _ejecutar(
      () => FotosService.reemplazar(_usuarioId, foto.nombre, archivo),
      'Foto cambiada',
    );
  }

  Future<void> _eliminar(Foto foto) => _ejecutar(
        () => FotosService.eliminar(_usuarioId, foto.nombre),
        'Foto eliminada',
      );

  /// Lanza la operación, enseña el resultado y recarga la lista.
  Future<void> _ejecutar(Future<void> Function() accion, String exito) async {
    setState(() => _ocupado = true);

    try {
      await accion();
      if (!mounted) return;
      _version++;
      _aviso(exito);
    } on Object catch (e) {
      if (!mounted) return;
      _aviso(
        e is ApiException ? e.mensaje : 'No se pudo conectar con el servidor.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }

    await _cargar();
  }

  void _aviso(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: error ? AppColors.danger : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Menú que sale al tocar una foto.
  Future<void> _opciones(Foto foto) async {
    final accion = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(
                Icons.photo_camera_rounded,
                color: AppColors.primary,
              ),
              title: const Text('Cambiar esta foto', style: AppTextStyles.body),
              onTap: () => Navigator.of(context).pop('cambiar'),
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
              ),
              title: Text(
                'Eliminar',
                style: AppTextStyles.body.copyWith(color: AppColors.danger),
              ),
              onTap: () => Navigator.of(context).pop('eliminar'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (accion == 'cambiar') await _cambiar(foto);
    if (accion == 'eliminar') await _eliminar(foto);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('Mis fotos', style: AppTextStyles.sectionTitle),
            const Spacer(),
            if (_ocupado)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Text(
                '${_fotos.length} de ${FotosService.maxFotos}',
                style: AppTextStyles.caption,
              ),
          ],
        ),
        const SizedBox(height: 10),
        _contenido(),
      ],
    );
  }

  Widget _contenido() {
    if (_cargando) {
      return const SizedBox(
        height: 104,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return _ErrorFotos(mensaje: _error!, onReintentar: _cargar);
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        for (final foto in _fotos)
          _Casilla(
            foto: foto,
            version: _version,
            onTap: _ocupado ? null : () => _opciones(foto),
          ),
        if (_fotos.length < FotosService.maxFotos)
          _BotonAgregar(onTap: _ocupado ? null : _agregar),
      ],
    );
  }
}

/// Una foto de la cuadrícula. La principal lleva su etiqueta.
class _Casilla extends StatelessWidget {
  const _Casilla({required this.foto, required this.version, this.onTap});

  final Foto foto;
  final int version;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              '${foto.url}?v=$version',
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progreso) => progreso == null
                  ? child
                  : const ColoredBox(
                      color: AppColors.surfaceMuted,
                      child: Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
              // Si la foto no carga, no se enseña el error rojo de Flutter.
              errorBuilder: (context, error, stack) => const ColoredBox(
                color: AppColors.surfaceMuted,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            if (foto.esPrincipal)
              Positioned(
                left: 6,
                bottom: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    'Principal',
                    style: AppTextStyles.chip.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textOnDark,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// El "+" que sale mientras quede espacio para más fotos.
class _BotonAgregar extends StatelessWidget {
  const _BotonAgregar({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.primaryLight, width: 1.4),
          ),
          child: const Center(
            child: Icon(Icons.add_rounded, size: 30, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

/// Lo que se ve cuando la API no responde.
class _ErrorFotos extends StatelessWidget {
  const _ErrorFotos({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.textMuted),
          const SizedBox(height: 8),
          Text(
            mensaje,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
