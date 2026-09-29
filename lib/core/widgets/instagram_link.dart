import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// El Instagram de una mascota, como enlace que abre el perfil de verdad.
///
/// Solo se enseña cuando ya hay match: es la forma de contactarse, porque la
/// app no tiene mensajes.
class InstagramLink extends StatelessWidget {
  const InstagramLink({
    super.key,
    required this.instagram,
    this.sobreFondoOscuro = false,
  });

  final String? instagram;

  /// `true` cuando va sobre el morado del aviso de match.
  final bool sobreFondoOscuro;

  /// Deja el link listo para abrirse: le pone https si falta y le quita la
  /// parte de `?stkn=...` que Instagram agrega al compartir.
  static String? limpiar(String? texto) {
    var link = texto?.trim();
    if (link == null || link.isEmpty) return null;

    // Si solo pusieron el usuario ("@aissac.47" o "aissac.47").
    if (!link.contains('/')) {
      return 'https://www.instagram.com/${link.replaceAll('@', '')}';
    }

    if (!link.startsWith('http')) link = 'https://$link';

    // Fuera los parametros de compartir: ensucian y no hacen falta.
    final corte = link.indexOf('?');
    return corte == -1 ? link : link.substring(0, corte);
  }

  /// Lo que se le enseña a la persona: solo el usuario, sin el https.
  static String comoTexto(String link) {
    final limpio = link.replaceFirst(RegExp(r'^https?://(www\.)?'), '');
    final partes = limpio.split('/').where((p) => p.isNotEmpty).toList();
    return partes.length > 1 ? '@${partes.last}' : limpio;
  }

  Future<void> _abrir(BuildContext context, String link) async {
    final abrio = await launchUrl(
      Uri.parse(link),
      mode: LaunchMode.externalApplication,
    );

    if (!abrio && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir Instagram'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final link = limpiar(instagram);

    final colorTexto =
        sobreFondoOscuro ? AppColors.textOnDark : AppColors.primary;
    final colorApagado =
        sobreFondoOscuro ? AppColors.textOnDarkMuted : AppColors.textMuted;

    if (link == null) {
      return Text(
        'Todavía no puso su Instagram',
        textAlign: TextAlign.center,
        style: AppTextStyles.body.copyWith(color: colorApagado, fontSize: 13.5),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _abrir(context, link),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  comoTexto(link),
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: colorTexto,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline,
                    decorationColor: colorTexto,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.open_in_new_rounded, size: 16, color: colorTexto),
            ],
          ),
        ),
      ),
    );
  }
}
