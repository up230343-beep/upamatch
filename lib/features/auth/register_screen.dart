import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/validaciones.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/form_error.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../core/widgets/step_progress_bar.dart';
import '../../data/api/cuentas_service.dart';
import '../../data/api/fotos_service.dart' show ApiException;
import '../../routes/app_routes.dart';
import '../onboarding/create_account_screen.dart';

/// 02a · Crear cuenta — paso 1 de 2: correo y contraseña.
///
/// Si sale bien la cuenta queda creada y con la sesión abierta, y sigue el
/// paso 2 ([CreateAccountScreen]) con los datos de la mascota.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _correoController = TextEditingController();
  final _contrasenaController = TextEditingController();
  final _confirmarController = TextEditingController();
  bool _oculta = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _correoController.dispose();
    _contrasenaController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  String? _validar() {
    final contrasena = _contrasenaController.text;
    return Validaciones.correo(_correoController.text) ??
        (contrasena.length < Validaciones.contrasenaMin
            ? 'La contraseña debe tener al menos '
                '${Validaciones.contrasenaMin} caracteres.'
            : null) ??
        (contrasena != _confirmarController.text
            ? 'Las contraseñas no coinciden.'
            : null);
  }

  Future<void> _crearCuenta() async {
    final error = _validar();
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _error = null;
      _cargando = true;
    });

    try {
      await CuentasService.registrar(
        _correoController.text.trim(),
        _contrasenaController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.createAccount,
        (_) => false,
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.mensaje;
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ojo = IconButton(
      icon: Icon(
        _oculta ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20,
        color: AppColors.textSecondary,
      ),
      onPressed: () => setState(() => _oculta = !_oculta),
    );

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
                18,
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
                      const Text('Paso 1 de 2', style: AppTextStyles.bodyMuted),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const StepProgressBar(step: 1, total: 2),
                  const SizedBox(height: 20),
                  const Text('Crea tu cuenta', style: AppTextStyles.title),
                  const SizedBox(height: 6),
                  const Text(
                    'Con tu correo y una contraseña podrás entrar después',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 22),
                  LabeledField(
                    label: 'Correo electrónico',
                    child: AppTextField(
                      controller: _correoController,
                      hintText: 'tucorreo@ejemplo.com',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Contraseña',
                    child: AppTextField(
                      controller: _contrasenaController,
                      hintText: 'Mínimo ${Validaciones.contrasenaMin} caracteres',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _oculta,
                      textInputAction: TextInputAction.next,
                      suffixIcon: ojo,
                    ),
                  ),
                  const SizedBox(height: 14),
                  LabeledField(
                    label: 'Confirmar contraseña',
                    child: AppTextField(
                      controller: _confirmarController,
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: _oculta,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _crearCuenta(),
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (_error != null) ...[
                    FormError(mensaje: _error),
                    const SizedBox(height: 14),
                  ],
                  GradientButton(
                    label: 'Crear cuenta',
                    loading: _cargando,
                    onPressed: _crearCuenta,
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      child: Text.rich(
                        TextSpan(
                          text: '¿Ya tienes cuenta? ',
                          style: AppTextStyles.bodyMuted,
                          children: [
                            TextSpan(
                              text: 'Inicia sesión',
                              style: AppTextStyles.link.copyWith(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const HomeIndicator(),
        ],
      ),
    );
  }
}
