import 'package:shared_preferences/shared_preferences.dart';

/// Quién está usando la app.
///
/// Al iniciar sesión se guarda el usuario en el teléfono, así la próxima vez
/// que se abra la app entra directo sin volver a pedir la contraseña.
abstract final class Sesion {
  static const _claveId = 'usuarioId';
  static const _claveNombre = 'nombre';

  static int? _usuarioId;
  static String _nombre = '';

  /// Id del usuario que inició sesión. Es nulo si no hay nadie.
  static int? get usuarioId => _usuarioId;

  static String get nombre => _nombre;

  static bool get hayCuenta => _usuarioId != null;

  /// Se llama al arrancar la app para saber si ya había alguien dentro.
  static Future<void> cargar() async {
    final guardado = await SharedPreferences.getInstance();
    _usuarioId = guardado.getInt(_claveId);
    _nombre = guardado.getString(_claveNombre) ?? '';
  }

  /// Guarda la sesión después de iniciar sesión o registrarse.
  static Future<void> guardar(int usuarioId, String nombre) async {
    _usuarioId = usuarioId;
    _nombre = nombre;

    final guardado = await SharedPreferences.getInstance();
    await guardado.setInt(_claveId, usuarioId);
    await guardado.setString(_claveNombre, nombre);
  }

  /// Borra la sesión al cerrar sesión.
  static Future<void> cerrar() async {
    _usuarioId = null;
    _nombre = '';

    final guardado = await SharedPreferences.getInstance();
    await guardado.remove(_claveId);
    await guardado.remove(_claveNombre);
  }
}
