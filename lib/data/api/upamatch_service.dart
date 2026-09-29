import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/profile.dart';
import '../models/solicitud.dart';
import 'api_config.dart';
import 'fotos_service.dart';

/// Resultado de dar "sí" o "no" a una mascota.
class ResultadoDecision {
  const ResultadoDecision({required this.huboMatch, this.perfil});

  final bool huboMatch;

  /// El perfil de la otra mascota, con su Instagram. Solo llega si hubo match.
  final Profile? perfil;
}

/// Las dos listas de la pantalla de solicitudes.
class Solicitudes {
  const Solicitudes({required this.pendientes, required this.aceptadas});

  final List<Solicitud> pendientes;
  final List<Solicitud> aceptadas;

  bool get vacio => pendientes.isEmpty && aceptadas.isEmpty;
}

/// Habla con la API: cuentas, perfiles y match.
///
/// Las fotos van por su propio camino, en [FotosService].
abstract final class UpaMatchService {
  static const _json = {'Content-Type': 'application/json'};

  static Uri _uri(String ruta) => Uri.parse('${ApiConfig.urlBase}/api$ruta');

  // ---------------------------------------------------------------- cuentas

  /// Crea la cuenta y el perfil de la mascota. Devuelve el id del usuario.
  static Future<({int usuarioId, String nombre})> registrar({
    required String correo,
    required String contrasena,
    required String nombre,
    required int edad,
    required ProfileKind tipo,
    required String raza,
    required String ciudad,
    required String sobreMi,
    required List<String> intereses,
    required String instagram,
  }) async {
    final respuesta = await http.post(
      _uri('/cuentas/registro'),
      headers: _json,
      body: jsonEncode({
        'correo': correo,
        'contrasena': contrasena,
        'nombre': nombre,
        'edad': edad,
        'tipo': tipo.name,
        'raza': raza,
        'ciudad': ciudad,
        'sobreMi': sobreMi,
        'intereses': intereses,
        'instagram': instagram,
      }),
    );

    return _comoCuenta(respuesta);
  }

  /// Inicia sesión. Falla si el correo o la contraseña no son correctos.
  static Future<({int usuarioId, String nombre})> iniciarSesion(
    String correo,
    String contrasena,
  ) async {
    final respuesta = await http.post(
      _uri('/cuentas/login'),
      headers: _json,
      body: jsonEncode({'correo': correo, 'contrasena': contrasena}),
    );

    return _comoCuenta(respuesta);
  }

  // --------------------------------------------------------------- perfiles

  /// El perfil propio, con su Instagram.
  static Future<Profile> miPerfil(int usuarioId) async {
    final respuesta = await http.get(_uri('/perfiles/$usuarioId'));

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensaje(respuesta, 'No se pudo cargar tu perfil.'));
    }

    return Profile.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }

  /// Guarda los cambios del perfil.
  static Future<Profile> guardarPerfil(int usuarioId, Profile perfil) async {
    final respuesta = await http.put(
      _uri('/perfiles/$usuarioId'),
      headers: _json,
      body: jsonEncode(perfil.toJson()),
    );

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensaje(respuesta, 'No se pudieron guardar los cambios.'));
    }

    return Profile.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }

  // ------------------------------------------------------------------ match

  /// Las mascotas que faltan por calificar.
  static Future<List<Profile>> siguientes(int usuarioId) async {
    final respuesta = await http.get(_uri('/match/siguientes/$usuarioId'));

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensaje(respuesta, 'No se pudieron cargar los perfiles.'));
    }

    final lista = jsonDecode(respuesta.body) as List<dynamic>;

    return [
      for (final item in lista) Profile.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Guarda el "sí" o el "no" y dice si con eso se hizo match.
  static Future<ResultadoDecision> decidir({
    required int usuarioId,
    required String otroId,
    required bool esSi,
  }) async {
    final respuesta = await http.post(
      _uri('/match/decidir'),
      headers: _json,
      body: jsonEncode({
        'deUsuarioId': usuarioId,
        'paraUsuarioId': int.tryParse(otroId) ?? 0,
        'esSi': esSi,
      }),
    );

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensaje(respuesta, 'No se pudo guardar tu respuesta.'));
    }

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;
    final perfil = datos['perfil'] as Map<String, dynamic>?;

    return ResultadoDecision(
      huboMatch: datos['huboMatch'] as bool? ?? false,
      perfil: perfil == null ? null : Profile.fromJson(perfil),
    );
  }

  /// Las solicitudes pendientes y las aceptadas.
  static Future<Solicitudes> solicitudes(int usuarioId) async {
    final respuesta = await http.get(_uri('/match/solicitudes/$usuarioId'));

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensaje(respuesta, 'No se pudieron cargar las solicitudes.'));
    }

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;

    List<Solicitud> leer(String clave) => [
          for (final item in (datos[clave] as List<dynamic>? ?? []))
            Solicitud.fromJson(item as Map<String, dynamic>),
        ];

    return Solicitudes(
      pendientes: leer('pendientes'),
      aceptadas: leer('aceptadas'),
    );
  }

  /// El perfil de otra mascota. El Instagram solo llega si ya son match.
  static Future<Profile> perfilDe(int usuarioId, String otroId) async {
    final respuesta = await http.get(_uri('/match/perfil/$usuarioId/$otroId'));

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensaje(respuesta, 'No se pudo cargar el perfil.'));
    }

    return Profile.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }

  // ----------------------------------------------------------------- ayudas

  static ({int usuarioId, String nombre}) _comoCuenta(http.Response respuesta) {
    if (respuesta.statusCode != 200) {
      throw ApiException(_mensaje(respuesta, 'No se pudo completar la operación.'));
    }

    final datos = jsonDecode(respuesta.body) as Map<String, dynamic>;

    return (
      usuarioId: (datos['usuarioId'] as num).toInt(),
      nombre: datos['nombre'] as String? ?? '',
    );
  }

  /// Los errores de la API vienen en texto plano, listos para enseñarse.
  static String _mensaje(http.Response respuesta, String porDefecto) {
    final cuerpo = respuesta.body.trim();
    return cuerpo.isEmpty ? porDefecto : cuerpo;
  }
}
