import 'package:shared_preferences/shared_preferences.dart';

/// Quién inició sesión. Se guarda en el dispositivo para que la próxima vez
/// la app entre directo sin volver a pedir la contraseña.
class Sesion {
  const Sesion({
    required this.token,
    required this.usuarioId,
    required this.correo,
    required this.tienePerfil,
  });

  final String token;
  final String usuarioId;
  final String correo;

  /// `false` mientras no termine el paso 2 del registro.
  final bool tienePerfil;

  factory Sesion.fromJson(Map<String, dynamic> json) => Sesion(
        token: json['token'] as String,
        usuarioId: json['usuarioId'] as String,
        correo: json['correo'] as String,
        tienePerfil: json['tienePerfil'] as bool,
      );

  Sesion copyWith({bool? tienePerfil}) => Sesion(
        token: token,
        usuarioId: usuarioId,
        correo: correo,
        tienePerfil: tienePerfil ?? this.tienePerfil,
      );
}

/// La sesión actual y cómo se guarda / se borra del dispositivo.
abstract final class SesionActual {
  static const _token = 'sesion.token';
  static const _usuarioId = 'sesion.usuarioId';
  static const _correo = 'sesion.correo';
  static const _tienePerfil = 'sesion.tienePerfil';

  static Sesion? _sesion;

  /// `null` si nadie ha iniciado sesión.
  static Sesion? get valor => _sesion;

  /// Lee la sesión guardada. Se llama una vez al abrir la app.
  static Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_token);
    final usuarioId = prefs.getString(_usuarioId);

    _sesion = token == null || usuarioId == null
        ? null
        : Sesion(
            token: token,
            usuarioId: usuarioId,
            correo: prefs.getString(_correo) ?? '',
            tienePerfil: prefs.getBool(_tienePerfil) ?? false,
          );
  }

  static Future<void> guardar(Sesion sesion) async {
    _sesion = sesion;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_token, sesion.token);
    await prefs.setString(_usuarioId, sesion.usuarioId);
    await prefs.setString(_correo, sesion.correo);
    await prefs.setBool(_tienePerfil, sesion.tienePerfil);
  }

  /// Cerrar sesión: se olvida todo lo guardado.
  static Future<void> cerrar() async {
    _sesion = null;
    final prefs = await SharedPreferences.getInstance();
    for (final clave in [_token, _usuarioId, _correo, _tienePerfil]) {
      await prefs.remove(clave);
    }
  }
}
