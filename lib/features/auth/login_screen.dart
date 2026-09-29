import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/validaciones.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/form_error.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../data/api/cuentas_service.dart';
import '../../data/api/fotos_service.dart' show ApiException;
import '../../routes/app_routes.dart';

/// 01 · Inicio de sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Revisa el formulario, pregunta a la API y solo entra si los datos son
  /// correctos. Si el correo existe o no, el mensaje es el mismo.
  Future<void> _entrar() async {
    final correo = _emailController.text.trim();
    final contrasena = _passwordController.text;

    final error = Validaciones.correo(correo) ??
        (contrasena.isEmpty ? 'Escribe tu contraseña.' : null);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _error = null;
      _cargando = true;
    });

    try {
      final sesion = await CuentasService.iniciarSesion(correo, contrasena);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        sesion.tienePerfil ? AppRoutes.home : AppRoutes.createAccount,
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
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.heroGradient),
        child: Stack(
          children: [
            const _HeroBlobs(),
            Column(
              children: [
                const MockStatusBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppTheme.pagePadding,
                      8,
                      AppTheme.pagePadding,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 26),
                        const Center(child: BrandLogo()),
                        const SizedBox(height: 18),
                        const Text(
                          'UpaMatch',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Personas, perros, gatos... todos merecen amor',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMuted,
                        ),
                        const SizedBox(height: 30),
                        LabeledField(
                          label: 'Correo electrónico',
                          child: AppTextField(
                            controller: _emailController,
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
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscure,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _entrar(),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscure
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 20,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            // TODO(backend): flujo de recuperación de contraseña.
                            onTap: () {},
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: AppTextStyles.link,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_error != null) ...[
                          FormError(mensaje: _error),
                          const SizedBox(height: 14),
                        ],
                        GradientButton(
                          label: 'Iniciar sesión',
                          loading: _cargando,
                          onPressed: _entrar,
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.register),
                            child: Text.rich(
                            TextSpan(
                              text: '¿No tienes cuenta? ',
                              style: AppTextStyles.bodyMuted,
                              children: [
                                TextSpan(
                                  text: 'Regístrate',
                                  style:
                                      AppTextStyles.link.copyWith(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
                const HomeIndicator(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Manchas decorativas del encabezado.
class _HeroBlobs extends StatelessWidget {
  const _HeroBlobs();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: -60,
              right: -70,
              child: Container(
                width: 260,
                height: 240,
                decoration: BoxDecoration(
                  color: AppColors.blobStrong,
                  borderRadius: BorderRadius.circular(110),
                ),
              ),
            ),
            Positioned(
              top: 130,
              left: -70,
              child: Container(
                width: 170,
                height: 170,
                decoration: const BoxDecoration(
                  color: AppColors.blobSoft,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
