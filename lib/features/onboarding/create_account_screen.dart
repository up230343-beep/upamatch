import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/form_error.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../core/widgets/pill_chip.dart';
import '../../core/widgets/step_progress_bar.dart';
import '../../data/api/cuentas_service.dart';
import '../../data/api/fotos_service.dart' show ApiException;
import '../../data/catalogos.dart';
import '../../data/models/mascota.dart';
import '../../data/models/profile.dart';
import '../../data/session/sesion.dart';
import '../../routes/app_routes.dart';

/// 02b · Crear cuenta — paso 2 de 2: datos de la mascota.
///
/// La misma pantalla sirve para "Editar perfil": si recibe [inicial], la
/// llena con esos datos, cambia los textos y al guardar regresa con la
/// [Mascota] guardada en lugar de ir al inicio.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, this.inicial});

  static const int step = 2;
  static const int totalSteps = 2;

  /// Datos actuales cuando se abre desde "Editar perfil".
  final Mascota? inicial;

  bool get editando => inicial != null;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  late final Mascota? _inicial = widget.inicial;

  late final _nombreController = TextEditingController(text: _inicial?.nombre);
  late final _ciudadController = TextEditingController(text: _inicial?.ciudad);
  late final _razaController = TextEditingController(text: _inicial?.raza);
  late final _descripcionController =
      TextEditingController(text: _inicial?.descripcion);
  late final _instagramController =
      TextEditingController(text: _inicial?.instagramUsuario);

  late ProfileKind _kind = _inicial?.tipo ?? ProfileKind.perro;
  late int? _edad = _inicial?.edad;
  late final Set<String> _intereses = {...?_inicial?.intereses};

  bool _guardando = false;
  String? _error;

  /// Los sugeridos más los que ya tenía guardados y no están en la lista.
  List<String> get _opcionesIntereses => [
        ...Catalogos.intereses,
        ..._intereses.where((i) => !Catalogos.intereses.contains(i)),
      ];

  @override
  void dispose() {
    _nombreController.dispose();
    _ciudadController.dispose();
    _razaController.dispose();
    _descripcionController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  String? _validar() {
    if (_nombreController.text.trim().isEmpty) return 'Escribe el nombre.';
    if (_edad == null) return 'Elige la edad.';
    if (_ciudadController.text.trim().isEmpty) return 'Escribe la ciudad.';
    return null;
  }

  Future<void> _guardar() async {
    final error = _validar();
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _error = null;
      _guardando = true;
    });

    final instagram = _instagramController.text.trim();

    try {
      final guardada = await CuentasService.guardarPerfil(Mascota(
        nombre: _nombreController.text.trim(),
        edad: _edad!,
        tipo: _kind,
        raza: _razaController.text.trim(),
        ciudad: _ciudadController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        intereses: _intereses.toList(),
        instagram: instagram.isEmpty ? null : instagram,
      ));
      if (!mounted) return;

      if (widget.editando) {
        Navigator.of(context).pop(guardada);
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.home,
          (_) => false,
        );
      }
    } on SesionVencida {
      if (mounted) await _salir();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _guardando = false;
      });
    }
  }

  /// En el registro, "atrás" cierra la sesión recién creada y vuelve al
  /// login; al editar, solo regresa al perfil.
  Future<void> _atras() async {
    if (widget.editando) {
      Navigator.of(context).maybePop();
      return;
    }
    await _salir();
  }

  Future<void> _salir() async {
    await SesionActual.cerrar();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.editando;

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
                        onTap: _atras,
                      ),
                      const Spacer(),
                      if (!editando)
                        const Flexible(
                          child: Text(
                            'Paso ${CreateAccountScreen.step} de '
                            '${CreateAccountScreen.totalSteps}',
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMuted,
                          ),
                        ),
                    ],
                  ),
                  if (!editando) ...[
                    const SizedBox(height: 16),
                    const StepProgressBar(
                      step: CreateAccountScreen.step,
                      total: CreateAccountScreen.totalSteps,
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    editando ? 'Editar perfil' : 'Cuéntanos sobre ti',
                    style: AppTextStyles.title,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Tu perfil puede ser tuyo o de tu mascota',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '¿De quién es este perfil?',
                    style: AppTextStyles.fieldLabel,
                  ),
                  const SizedBox(height: 10),
                  _KindGrid(
                    selected: _kind,
                    onChanged: (kind) => setState(() {
                      _kind = kind;
                      if (_edad != null && !_edadesPara(kind).contains(_edad)) {
                        _edad = null;
                      }
                    }),
                  ),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: '¿Cómo se llama?',
                    child: AppTextField(
                      controller: _nombreController,
                      maxLength: 40,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Edad',
                          child: AppDropdownBox(
                            value: _edad == null ? 'Elige' : _textoEdad(_edad!),
                            onTap: _pickAge,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LabeledField(
                          label: 'Ciudad',
                          child: AppTextField(controller: _ciudadController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: _kind == ProfileKind.persona
                        ? 'Ocupación (opcional)'
                        : 'Raza (opcional)',
                    child: AppTextField(
                      controller: _razaController,
                      hintText: _kind == ProfileKind.persona
                          ? 'Ej. Veterinaria'
                          : 'Ej. Golden Retriever',
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Sobre mí (opcional)',
                    child: AppTextField(
                      controller: _descripcionController,
                      hintText: '¿Qué le gusta? ¿Qué busca?',
                      maxLines: 3,
                      maxLength: 300,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Intereses (hasta ${Catalogos.interesesMax})',
                    style: AppTextStyles.fieldLabel,
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final opcion in _opcionesIntereses)
                          PillChip.choice(
                            label: opcion,
                            selected: _intereses.contains(opcion),
                            onTap: () => setState(() {
                              if (!_intereses.remove(opcion) &&
                                  _intereses.length < Catalogos.interesesMax) {
                                _intereses.add(opcion);
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  LabeledField(
                    label: 'Instagram (opcional)',
                    child: AppTextField(
                      controller: _instagramController,
                      hintText: '@usuario o link',
                      prefixIcon: Icons.alternate_email_rounded,
                      keyboardType: TextInputType.url,
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (_error != null) ...[
                    FormError(mensaje: _error),
                    const SizedBox(height: 14),
                  ],
                  GradientButton(
                    label: editando ? 'Guardar cambios' : 'Continuar',
                    loading: _guardando,
                    onPressed: _guardar,
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

  static List<int> _edadesPara(ProfileKind kind) => kind == ProfileKind.persona
      ? [for (var i = 18; i <= 99; i++) i]
      : [for (var i = 0; i <= 30; i++) i];

  static String _textoEdad(int edad) => switch (edad) {
        0 => 'Menos de 1 año',
        1 => '1 año',
        _ => '$edad años',
      };

  Future<void> _pickAge() async {
    final options = _edadesPara(_kind);

    final picked = await showModalBottomSheet<int>(
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
                title: Text(_textoEdad(option), style: AppTextStyles.body),
                trailing: option == _edad
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );

    if (picked != null && mounted) setState(() => _edad = picked);
  }
}

class _KindGrid extends StatelessWidget {
  const _KindGrid({required this.selected, required this.onChanged});

  final ProfileKind selected;
  final ValueChanged<ProfileKind> onChanged;

  static const Map<ProfileKind, Color> _avatarColors = {
    ProfileKind.persona: AppColors.avatarBlue,
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
