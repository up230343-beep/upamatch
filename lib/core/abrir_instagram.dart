import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre el perfil de Instagram en la app de Instagram (o en el navegador si
/// no está instalada). Solo abre el link: no usa ninguna API de Instagram.
Future<void> abrirInstagram(BuildContext context, String link) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final abierto = await launchUrl(
    Uri.parse(link),
    mode: LaunchMode.externalApplication,
  );
  if (!abierto) {
    messenger?.showSnackBar(
      const SnackBar(content: Text('No se pudo abrir Instagram.')),
    );
  }
}
