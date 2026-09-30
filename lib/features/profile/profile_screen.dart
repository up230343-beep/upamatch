import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
<<<<<<< HEAD
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/instagram_link.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/sesion.dart';
import '../../data/api/upamatch_service.dart';
=======
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/form_error.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/api/api_config.dart';
import '../../data/api/cuentas_service.dart';
import '../../data/api/fotos_service.dart';
import '../../data/mis_solicitudes.dart';
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
import '../../data/mock/mock_data.dart';
import '../../data/models/mascota.dart';
import '../../data/session/sesion.dart';
import '../../routes/app_routes.dart';
import 'widgets/mis_fotos.dart';

<<<<<<< HEAD
/// Mi perfil: las fotos y los datos de la mascota, todo editable aquí mismo.
=======
/// 05 · Perfil: los datos reales de la mascota de quien inició sesión.
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
<<<<<<< HEAD
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
=======
  Mascota? _mascota;
  bool _cargando = true;
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

<<<<<<< HEAD
  @override
  void dispose() {
    _nombre.dispose();
    _raza.dispose();
    _ciudad.dispose();
    _sobreMi.dispose();
    _instagram.dispose();
    super.dispose();
  }

=======
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
<<<<<<< HEAD
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
=======
      final mascota = await CuentasService.obtenerPerfil();
      if (!mounted) return;
      if (mascota == null) {
        // Tiene cuenta pero no terminó el registro: se manda al paso 2.
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.createAccount,
          (_) => false,
        );
        return;
      }
      setState(() {
        _mascota = mascota;
        _cargando = false;
      });
    } on SesionVencida {
      await _cerrarSesion();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
        _cargando = false;
      });
    }
  }

<<<<<<< HEAD
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
=======
  Future<void> _editar() async {
    final guardada = await Navigator.of(context).pushNamed(
      AppRoutes.editProfile,
      arguments: _mascota,
    );
    if (guardada is Mascota && mounted) setState(() => _mascota = guardada);
  }

  Future<void> _cerrarSesion() async {
    await SesionActual.cerrar();
    MisSolicitudes.instancia.reiniciar();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
    );
  }

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
=======
    final mascota = _mascota;
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6

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
<<<<<<< HEAD
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
=======
          const SizedBox(height: 16),
          if (_cargando)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (mascota == null) ...[
            FormError(mensaje: _error),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _cargar,
                child: const Text('Reintentar', style: AppTextStyles.link),
              ),
            ),
          ] else ...[
            _ProfileHeaderCard(mascota: mascota),
            const SizedBox(height: 22),
            const MisFotos(),
            const SizedBox(height: 22),
            const Text('Sobre mí', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 10),
            _Card(
              child: Text(
                mascota.descripcion.isEmpty
                    ? 'Todavía no escribes nada. Tócale a "Editar perfil".'
                    : mascota.descripcion,
                style: mascota.descripcion.isEmpty
                    ? AppTextStyles.bodyMuted
                    : AppTextStyles.body.copyWith(height: 1.45),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Intereses', style: AppTextStyles.sectionTitle),
            const SizedBox(height: 10),
            if (mascota.intereses.isEmpty)
              const Text(
                'Sin intereses todavía.',
                style: AppTextStyles.bodyMuted,
              )
            else
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final interes in mascota.intereses)
                      PillChip.choice(label: interes, selected: true),
                  ],
                ),
              ),
            if (mascota.instagram.isNotEmpty) ...[
              const SizedBox(height: 22),
              const Text('Instagram', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 10),
              _Card(
                child: Row(
                  children: [
                    const Icon(
                      Icons.alternate_email_rounded,
                      size: 19,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        mascota.instagramUsuario,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 22),
          const Text('Cuenta', style: AppTextStyles.sectionTitle),
          const SizedBox(height: 10),
          _MenuRow(
            icon: Icons.edit_outlined,
            label: 'Editar perfil',
            onTap: mascota == null ? null : _editar,
          ),
          const SizedBox(height: 10),
          // TODO(backend): cada fila debe abrir su pantalla real.
          _MenuRow(
            icon: Icons.tune_rounded,
            label: 'Preferencias de búsqueda',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _MenuRow(
            icon: Icons.notifications_none_rounded,
            label: 'Notificaciones',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _MenuRow(
            icon: Icons.lock_outline_rounded,
            label: 'Privacidad y seguridad',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _MenuRow(
            icon: Icons.help_outline_rounded,
            label: 'Ayuda',
            onTap: () {},
          ),
          const SizedBox(height: 16),
          _MenuRow(
            icon: Icons.logout_rounded,
            label: 'Cerrar sesión',
            danger: true,
            showChevron: false,
            onTap: _cerrarSesion,
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD
  Future<void> _elegirEdad() async {
    final elegida = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusSheet),
        ),
=======
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.mascota});

  final Mascota mascota;

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              AvatarCircle(
                size: 96,
                // La foto principal que esta en Azure. Si todavia no hay
                // ninguna, AvatarCircle deja el hueco.
                photoUrl: FotosService.urlPrincipal(ApiConfig.usuarioId),
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 2.5),
                  ),
                  child: const Icon(
                    Icons.photo_camera_rounded,
                    size: 15,
                    color: AppColors.textOnDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  mascota.titulo,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            mascota.subtitulo,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMuted,
          ),
          const SizedBox(height: 18),
          const _StatsRow(),
        ],
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
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
