import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/avatar_circle.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/form_error.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/api/api_config.dart';
import '../../data/api/cuentas_service.dart';
import '../../data/api/fotos_service.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/mascota.dart';
import '../../data/session/sesion.dart';
import '../../routes/app_routes.dart';
import 'widgets/mis_fotos.dart';

/// 05 · Perfil: los datos reales de la mascota de quien inició sesión.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Mascota? _mascota;
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
        _cargando = false;
      });
    }
  }

  Future<void> _editar() async {
    final guardada = await Navigator.of(context).pushNamed(
      AppRoutes.editProfile,
      arguments: _mascota,
    );
    if (guardada is Mascota && mounted) setState(() => _mascota = guardada);
  }

  Future<void> _cerrarSesion() async {
    await SesionActual.cerrar();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mascota = _mascota;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pagePadding,
        0,
        AppTheme.pagePadding,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Flexible(
                child: Text(
                  'Perfil',
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title,
                ),
              ),
              const Spacer(),
              CircleIconButton(
                icon: Icons.settings_outlined,
                // TODO(backend): pantalla de ajustes.
                onTap: () {},
              ),
            ],
          ),
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
            if (mascota.instagramUsuario case final instagram?) ...[
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
                        instagram,
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
          ),
        ],
      ),
    );
  }
}

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
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    final stats = MockData.profileStats;

    return Row(
      children: [
        for (var i = 0; i < stats.length; i++) ...[
          if (i > 0)
            Container(
              width: 1,
              height: 30,
              color: AppColors.border,
            ),
          Expanded(
            child: Column(
              children: [
                Text(
                  stats[i].value,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(stats[i].label, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.danger = false,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool danger;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? AppColors.danger : AppColors.primary;

    return Material(
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
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 19, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: danger ? AppColors.danger : AppColors.textPrimary,
                  ),
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 22,
                  color: AppColors.textMuted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSheet - 4),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
