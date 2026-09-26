import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../routes/app_routes.dart';

/// 01 · Inicio de sesión
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController(text: 'contrasena');
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                          ),
                        ),
                        const SizedBox(height: 14),
                        LabeledField(
                          label: 'Contraseña',
                          child: AppTextField(
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscure,
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
                        GradientButton(
                          label: 'Iniciar sesión',
                          // TODO(backend): autenticar y navegar según respuesta.
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.createAccount),
                        ),
                        const SizedBox(height: 22),
                        const _OrDivider(),
                        const SizedBox(height: 18),
                        const _SocialRow(),
                        const SizedBox(height: 28),
                        Center(
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: AppColors.borderStrong, height: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('o continúa con', style: AppTextStyles.caption),
        ),
        Expanded(child: Divider(color: AppColors.borderStrong, height: 1)),
      ],
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Text(
              'G',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFFEA4335),
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: Icon(Icons.apple, size: 19, color: AppColors.textPrimary),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: 'Facebook',
            icon: Text(
              'f',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1877F2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon});

  final String label;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusField),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        // TODO(backend): login social.
        onTap: () {},
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 20, child: Center(child: icon)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.chip.copyWith(fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
