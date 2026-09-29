import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/instagram_link.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/sesion.dart';
import '../../data/api/upamatch_service.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/profile.dart';
import '../../routes/app_routes.dart';
import 'widgets/mis_fotos.dart';

/// Mi perfil: las fotos y los datos de la mascota, todo editable aquí mismo.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nombre = TextEditingController();
  final _raza = TextEditingController();
  final _ciudad = TextEditingController();
  final _sobreMi = TextEditingController();
  final _instagram = TextEditingController();

  ProfileKind _tipo = ProfileKind.perro;
  int _edad = 1;
  final Set<String> _intereses = {};

  bool _cargando = true;
  bool _guardando = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _raza.dispose();
    _ciudad.dispose();
    _sobreMi.dispose();
    _instagram.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final perfil = await UpaMatchService.miPerfil(Sesion.usuarioId!);
      if (!mounted) return;

      setState(() {
        _nombre.text = perfil.name;
        _raza.text = perfil.breed;
        _ciudad.text = perfil.city;
        _sobreMi.text = perfil.about;
        _instagram.text = perfil.instagram ?? '';
        _tipo = perfil.kind;
        _edad = perfil.age < 1 ? 1 : perfil.age;
        _intereses
          ..clear()
          ..addAll(perfil.tags);
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

  Future<void> _guardar() async {
    if (_nombre.text.trim().length < 2) {
      _aviso('Ponle nombre a tu mascota.', error: true);
      return;
    }

    if (_raza.text.trim().isEmpty) {
      _aviso('Escribe la raza de tu mascota.', error: true);
      return;
    }

    if (_ciudad.text.trim().isEmpty) {
      _aviso('Escribe tu ciudad.', error: true);
      return;
    }

    if (_intereses.isEmpty) {
      _aviso('Elige al menos una opción en "¿Qué buscas?".', error: true);
      return;
    }

    if (InstagramLink.limpiar(_instagram.text) == null) {
      _aviso('Escribe tu Instagram: es como te van a contactar.', error: true);
      return;
    }

    setState(() => _guardando = true);

    try {
      await UpaMatchService.guardarPerfil(
        Sesion.usuarioId!,
        Profile(
          id: '${Sesion.usuarioId}',
          name: _nombre.text.trim(),
          age: _edad,
          kind: _tipo,
          breed: _raza.text.trim(),
          city: _ciudad.text.trim(),
          distanceKm: 0,
          about: _sobreMi.text.trim(),
          tags: _intereses.toList(),
          instagram: _instagram.text.trim(),
        ),
      );

      if (!mounted) return;
      _aviso('Perfil guardado');
    } on Object catch (e) {
      if (!mounted) return;
      _aviso(
        e is ApiException ? e.mensaje : 'No se pudo conectar con el servidor.',
        error: true,
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _cerrarSesion() async {
    await Sesion.cerrar();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
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

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

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
          const Text('Mi perfil', style: AppTextStyles.title),
          const SizedBox(height: 16),
          if (_error != null) ...[
            _ErrorCard(mensaje: _error!, onReintentar: _cargar),
            const SizedBox(height: 18),
          ],
          // Las fotos ya se guardan solas en Azure, no hace falta darle guardar.
          const MisFotos(),
          const SizedBox(height: 24),
          const Text('Datos de mi mascota', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 12),
          LabeledField(
            label: '¿Cómo se llama? *',
            child: AppTextField(controller: _nombre),
          ),
          const SizedBox(height: 14),
          const Text('¿Qué mascota es?', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              children: [
                for (final tipo in ProfileKind.values)
                  PillChip.choice(
                    label: '${tipo.emoji} ${tipo.label}',
                    selected: tipo == _tipo,
                    onTap: () => setState(() => _tipo = tipo),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledField(
                  label: 'Edad',
                  child: AppDropdownBox(
                    value: '$_edad ${_edad == 1 ? 'año' : 'años'}',
                    onTap: _elegirEdad,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledField(
                  label: 'Raza *',
                  child: AppTextField(controller: _raza),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Ciudad *',
            child: AppTextField(controller: _ciudad),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Sobre mí (opcional)',
            child: AppTextField(controller: _sobreMi),
          ),
          const SizedBox(height: 14),
          LabeledField(
            label: 'Mi Instagram *',
            child: AppTextField(
              controller: _instagram,
              hintText: 'https://instagram.com/tuusuario',
              prefixIcon: Icons.alternate_email_rounded,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Solo lo ven las mascotas con las que hagas match.',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 18),
          const Text('¿Qué buscas? *', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final opcion in MockData.lookingForOptions)
                  PillChip.choice(
                    label: opcion,
                    selected: _intereses.contains(opcion),
                    onTap: () => setState(() {
                      if (!_intereses.remove(opcion)) _intereses.add(opcion);
                    }),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: _guardando ? 'Guardando...' : 'Guardar cambios',
            onPressed: _guardando ? null : _guardar,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: _cerrarSesion,
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: Text(
              'Cerrar sesión',
              style: AppTextStyles.body.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _elegirEdad() async {
    final elegida = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusSheet),
        ),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (var i = 1; i <= 20; i++)
              ListTile(
                title: Text(
                  '$i ${i == 1 ? 'año' : 'años'}',
                  style: AppTextStyles.body,
                ),
                trailing: i == _edad
                    ? const Icon(
                        Icons.check_rounded,
                        color: AppColors.primary,
                        size: 20,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(i),
              ),
          ],
        ),
      ),
    );

    if (elegida != null && mounted) setState(() => _edad = elegida);
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(mensaje, textAlign: TextAlign.center, style: AppTextStyles.bodyMuted),
          TextButton(onPressed: onReintentar, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
