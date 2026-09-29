import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/mascota.dart';
import '../session/sesion.dart';
import 'api_config.dart';
import 'fotos_service.dart' show ApiException;

/// El token guardado ya no sirve (venció o el usuario ya no existe): hay que
/// volver a iniciar sesión.
class SesionVencida extends ApiException {
  SesionVencida() : super('Tu sesión terminó. Vuelve a iniciar sesión.');
}

/// Habla con la API de cuentas: registro, inicio de sesión y perfil.
abstract final class CuentasService {
  /// Se cambia en las pruebas por un cliente falso.
  static http.Client cliente = http.Client();

  static const _espera = Duration(seconds: 10);
  static const _sinConexion =
      'No se pudo conectar con el servidor. Intenta de nuevo.';

  static Uri _uri(String ruta) => Uri.parse('${ApiConfig.cuentasUrlBase}$ruta');

  static Map<String, String> _encabezados({bool conToken = false}) => {
        'Content-Type': 'application/json; charset=utf-8',
        if (conToken && SesionActual.valor != null)
          'Authorization': 'Bearer ${SesionActual.valor!.token}',
      };

  /// Paso 1 del registro. Si sale bien, la sesión queda guardada.
  static Future<Sesion> registrar(String correo, String contrasena) =>
      _entrar('/api/auth/registro', correo, contrasena);

  /// Si sale bien, la sesión queda guardada.
  static Future<Sesion> iniciarSesion(String correo, String contrasena) =>
      _entrar('/api/auth/login', correo, contrasena);

  static Future<Sesion> _entrar(
    String ruta,
    String correo,
    String contrasena,
  ) async {
    final respuesta = await _enviar(() => cliente.post(
          _uri(ruta),
          headers: _encabezados(),
          body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
        ));

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensajeDe(respuesta, 'No se pudo entrar.'));
    }

    final sesion = Sesion.fromJson(_json(respuesta));
    await SesionActual.guardar(sesion);
    return sesion;
  }

  /// Comprueba que la sesión guardada siga sirviendo. Devuelve `false` solo
  /// si la API dice que no; si no hay conexión se da por buena, para que la
  /// app abra igual.
  static Future<bool> sesionSigueValida() async {
    try {
      final respuesta = await cliente
          .get(_uri('/api/auth/yo'), headers: _encabezados(conToken: true))
          .timeout(const Duration(seconds: 4));
      return respuesta.statusCode != 401;
    } on Object {
      return true;
    }
  }

  /// `null` si todavía no llenó los datos de su mascota.
  static Future<Mascota?> obtenerPerfil() async {
    final respuesta = await _enviar(() => cliente.get(
          _uri('/api/perfil'),
          headers: _encabezados(conToken: true),
        ));

    if (respuesta.statusCode == 404) return null;
    _revisar(respuesta, 'No se pudo cargar tu perfil.');
    return Mascota.fromJson(_json(respuesta));
  }

  /// Crea o actualiza los datos de la mascota y devuelve lo que quedó guardado.
  static Future<Mascota> guardarPerfil(Mascota mascota) async {
    final respuesta = await _enviar(() => cliente.put(
          _uri('/api/perfil'),
          headers: _encabezados(conToken: true),
          body: jsonEncode(mascota.toJson()),
        ));

    _revisar(respuesta, 'No se pudo guardar tu perfil.');

    final sesion = SesionActual.valor;
    if (sesion != null && !sesion.tienePerfil) {
      await SesionActual.guardar(sesion.copyWith(tienePerfil: true));
    }
    return Mascota.fromJson(_json(respuesta));
  }

  static Future<http.Response> _enviar(
    Future<http.Response> Function() peticion,
  ) async {
    try {
      return await peticion().timeout(_espera);
    } on TimeoutException {
      throw ApiException(_sinConexion);
    } on http.ClientException {
      throw ApiException(_sinConexion);
    }
  }

  static void _revisar(http.Response respuesta, String porDefecto) {
    if (respuesta.statusCode == 401) throw SesionVencida();
    if (respuesta.statusCode != 200) {
      throw ApiException(_mensajeDe(respuesta, porDefecto));
    }
  }

  static Map<String, dynamic> _json(http.Response respuesta) =>
      jsonDecode(utf8.decode(respuesta.bodyBytes)) as Map<String, dynamic>;

  /// Los errores de la API vienen en texto plano, listos para enseñarse.
  static String _mensajeDe(http.Response respuesta, String porDefecto) {
    final cuerpo = utf8.decode(respuesta.bodyBytes).trim();
    return cuerpo.isEmpty || cuerpo.startsWith('{') ? porDefecto : cuerpo;
  }
}
