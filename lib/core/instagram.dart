/// Reglas del Instagram del perfil. Son las mismas que revisa la API
/// (`Reglas.TryNormalizarInstagram` en el backend).
///
/// Se acepta "@usuario", "usuario" o el link completo.
abstract final class Instagram {
  static final RegExp _link = RegExp(
    r'^(https?://)?(www\.)?instagram\.com/([^/?#]+)/?([?#].*)?$',
    caseSensitive: false,
  );
  static final RegExp _usuario = RegExp(r'^[A-Za-z0-9._]{1,30}$');

  /// Mensaje del problema, o `null` si está bien.
  static String? validar(String valor) {
    final texto = valor.trim();
    if (texto.isEmpty) return 'Escribe tu Instagram.';
    if (!_usuario.hasMatch(_soloUsuario(texto))) {
      return 'El Instagram no es válido. Escribe tu usuario (@usuario) o el link.';
    }
    return null;
  }

  /// "@usuario" a partir del link completo o de lo que escribió.
  static String usuario(String linkOTexto) {
    final texto = linkOTexto.trim();
    return texto.isEmpty ? '' : '@${_soloUsuario(texto)}';
  }

  static String _soloUsuario(String texto) =>
      _link.firstMatch(texto)?.group(3) ?? texto.replaceFirst('@', '');
}
