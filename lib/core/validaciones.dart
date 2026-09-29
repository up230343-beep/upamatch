/// Validaciones de formularios. Son las mismas reglas que revisa la API
/// (`backend/UpaMatch.Api/Reglas.cs`), para avisar antes de mandar nada.
abstract final class Validaciones {
  static const int contrasenaMin = 8;

  static final RegExp _correo = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool correoValido(String correo) => _correo.hasMatch(correo.trim());

  /// Mensaje del primer problema del correo, o `null` si está bien.
  static String? correo(String valor) {
    if (valor.trim().isEmpty) return 'Escribe tu correo.';
    if (!correoValido(valor)) return 'Escribe un correo válido.';
    return null;
  }
}
