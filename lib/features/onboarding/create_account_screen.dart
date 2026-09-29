import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/profile.dart';
import '../../core/widgets/instagram_link.dart';
import '../../data/api/fotos_service.dart';
import '../../data/api/sesion.dart';
import '../../data/api/upamatch_service.dart';
import '../../routes/app_routes.dart';

/// 02 · Crear cuenta
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _breedController = TextEditingController();
  final _aboutController = TextEditingController();
  final _instagramController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  ProfileKind _kind = ProfileKind.perro;
  String _age = '1 año';
  final Set<String> _lookingFor = {'Amistad'};
  bool _creando = false;

  /// Crea la cuenta y entra a la app.
  Future<void> _crearCuenta() async {
    final correo = _emailController.text.trim();

    if (!correo.contains('@') || !correo.contains('.')) {
      _aviso('Escribe un correo valido.');
      return;
    }

    if (_passwordController.text.length < 6) {
      _aviso('La contrasena debe tener al menos 6 caracteres.');
      return;
    }

    if (_nameController.text.trim().length < 2) {
      _aviso('Ponle nombre a tu mascota.');
      return;
    }

    if (_breedController.text.trim().isEmpty) {
      _aviso('Escribe la raza de tu mascota.');
      return;
    }

    if (_cityController.text.trim().isEmpty) {
      _aviso('Escribe tu ciudad.');
      return;
    }

    if (_lookingFor.isEmpty) {
      _aviso('Elige al menos una opción en "¿Qué buscas?".');
      return;
    }

    // El Instagram es como se contactan cuando hay match: sin el, la app no
    // sirve de nada.
    if (InstagramLink.limpiar(_instagramController.text) == null) {
      _aviso('Escribe tu Instagram: es como te van a contactar.');
      return;
    }

    setState(() => _creando = true);

    try {
      final cuenta = await UpaMatchService.registrar(
        correo: correo,
        contrasena: _passwordController.text,
        nombre: _nameController.text.trim(),
        // La edad se guarda como numero: "3 años" -> 3
        edad: int.tryParse(_age.split(' ').first) ?? 1,
        tipo: _kind,
        raza: _breedController.text.trim(),
        ciudad: _cityController.text.trim(),
        sobreMi: _aboutController.text.trim(),
        intereses: _lookingFor.toList(),
        instagram: _instagramController.text.trim(),
      );

      await Sesion.guardar(cuenta.usuarioId, cuenta.nombre);

      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
    } on Object catch (e) {
      if (!mounted) return;
      _aviso(e is ApiException ? e.mensaje : 'No se pudo conectar con el servidor.');
    } finally {
      if (mounted) setState(() => _creando = false);
    }
  }

  void _aviso(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _breedController.dispose();
    _aboutController.dispose();
    _instagramController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MockStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                6,
                AppTheme.pagePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.chevron_left_rounded,
                        size: 40,
                        iconSize: 24,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Cuéntanos sobre ti', style: AppTextStyles.title),
                  const SizedBox(height: 6),
                  const Text(
                    'Crea el perfil de tu mascota. Los campos con * son '
                    'obligatorios.',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 22),
                  LabeledField(
                    label: 'Correo electrónico *',
                    child: AppTextField(
                      controller: _emailController,
                      hintText: 'tucorreo@ejemplo.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Contraseña *',
                    child: AppTextField(
                      controller: _passwordController,
                      hintText: 'Mínimo 6 caracteres',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '¿Qué mascota es?',
                    style: AppTextStyles.fieldLabel,
                  ),
                  const SizedBox(height: 10),
                  _KindGrid(
                    selected: _kind,
                    onChanged: (kind) => setState(() => _kind = kind),
                  ),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: '¿Cómo se llama? *',
                    child: AppTextField(controller: _nameController),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Raza *',
                    child: AppTextField(
                      controller: _breedController,
                      hintText: 'Golden Retriever, Siamés...',
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
                            value: _age,
                            onTap: _pickAge,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LabeledField(
                          label: 'Ciudad *',
                          child: AppTextField(controller: _cityController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LabeledField(
                    label: 'Sobre mí (opcional)',
                    child: AppTextField(
                      controller: _aboutController,
                      hintText: 'Cuéntanos algo de tu mascota',
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Tu Instagram *',
                    child: AppTextField(
                      controller: _instagramController,
                      hintText: 'https://instagram.com/tuusuario',
                      prefixIcon: Icons.alternate_email_rounded,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Solo se comparte cuando hacen match.',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: 16),
                  const Text('¿Qué buscas? *', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in MockData.lookingForOptions)
                          PillChip.choice(
                            label: option,
                            selected: _lookingFor.contains(option),
                            onTap: () => setState(() {
                              if (!_lookingFor.remove(option)) {
                                _lookingFor.add(option);
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: _creando ? 'Creando cuenta...' : 'Crear cuenta',
                    onPressed: _creando ? null : _crearCuenta,
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          const HomeIndicator(),
        ],
      ),
    );
  }

  Future<void> _pickAge() async {
    final options = <String>[
      for (var i = 1; i <= 15; i++) '$i ${i == 1 ? 'año' : 'años'}',
    ];

    final picked = await showModalBottomSheet<String>(
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
            for (final option in options)
              ListTile(
                title: Text(option, style: AppTextStyles.body),
                trailing: option == _age
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );

    if (picked != null && mounted) setState(() => _age = picked);
  }
}


class _KindGrid extends StatelessWidget {
  const _KindGrid({required this.selected, required this.onChanged});

  final ProfileKind selected;
  final ValueChanged<ProfileKind> onChanged;

  static const Map<ProfileKind, Color> _avatarColors = {
    ProfileKind.perro: AppColors.avatarTan,
    ProfileKind.gato: AppColors.avatarPeach,
    ProfileKind.otro: AppColors.avatarMint,
  };

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 165 / 76,
      children: [
        for (final kind in ProfileKind.values)
          _KindCard(
            kind: kind,
            avatarColor: _avatarColors[kind]!,
            selected: kind == selected,
            onTap: () => onChanged(kind),
          ),
      ],
    );
  }
}

class _KindCard extends StatelessWidget {
  const _KindCard({
    required this.kind,
    required this.avatarColor,
    required this.selected,
    required this.onTap,
  });

  final ProfileKind kind;
  final Color avatarColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(
                  color: selected ? AppColors.primaryLight : AppColors.border,
                  width: selected ? 1.8 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      kind.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      kind.label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selected)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.textOnDark,
              ),
            ),
          ),
      ],
    );
  }
}
