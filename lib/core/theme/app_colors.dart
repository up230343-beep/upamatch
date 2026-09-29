import 'package:flutter/material.dart';

/// Paleta única de UpaMatch.
///
/// Todos los colores del mockup de Figma viven aquí: ninguna pantalla debe
/// declarar un `Color(0x...)` suelto.
abstract final class AppColors {
  // Marca
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryDark = Color(0xFF6D28D9);
  static const Color primaryLight = Color(0xFFA855F7);

  // Superficies
  static const Color background = Color(0xFFF7F3FE);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF2ECFD);
  static const Color border = Color(0xFFEAE3F8);
  static const Color borderStrong = Color(0xFFDCD3F2);

  // Texto
  static const Color textPrimary = Color(0xFF1C1733);
  static const Color textSecondary = Color(0xFF706C86);
  static const Color textMuted = Color(0xFF9A96AD);
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Blanco atenuado: para los textos secundarios sobre fondo morado u oscuro.
  static const Color textOnDarkMuted = Color(0xCCFFFFFF);

  // Acentos
  static const Color dark = Color(0xFF231D3A);
  static const Color danger = Color(0xFFF0424E);
  static const Color star = Color(0xFFFBB040);
  static const Color verified = Color(0xFF3BA4F5);

  // Fondos de avatar (tarjetas "¿De quién es este perfil?")
  static const Color avatarBlue = Color(0xFFD9E8FB);
  static const Color avatarTan = Color(0xFFFBE7D2);
  static const Color avatarPeach = Color(0xFFFCDEC9);
  static const Color avatarMint = Color(0xFFDFF3E4);

  // Blobs decorativos del login
  static const Color blobStrong = Color(0xFFE4D5FB);
  static const Color blobSoft = Color(0xFFEFE6FD);

  /// Degradado de los botones principales y del logo.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF7B2FF7), Color(0xFFA855F7)],
  );

  /// Degradado vertical de la tarjeta de perfil en "Explorar".
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFC5B0F6), Color(0xFF6C34CC)],
  );

  /// Degradado suave del encabezado del login.
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF3EBFE), Color(0xFFF7F3FE)],
  );

  /// Sombra estándar de las tarjetas blancas.
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0F1C1733),
      blurRadius: 18,
      offset: Offset(0, 6),
    ),
  ];

  /// Sombra de los botones flotantes circulares (like / pasar / super like).
  static const List<BoxShadow> floatingShadow = [
    BoxShadow(
      color: Color(0x1A1C1733),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
