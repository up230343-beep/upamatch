import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/profile.dart';
import '../models/solicitud.dart';
import '../models/swipe_decision.dart';
import '../session/sesion.dart';
import 'api_config.dart';
import 'cuentas_service.dart';
import 'fotos_service.dart' show ApiException, FotosService;

/// Lo que responde la API al dar "sí" o "no".
class ResultadoCalificacion {
  const ResultadoCalificacion({required this.match, this.perfil});

  /// `true` si con este "sí" se completó el match (o ya lo había).
  final bool match;

  /// Solo si hay [match]: el otro perfil, ya con su Instagram.
  final Solicitud? perfil;
}

/// Las dos listas de la pantalla de solicitudes.
class Solicitudes {
  const Solicitudes({required this.pendientes, required this.aceptadas});

  static const vacias = Solicitudes(pendientes: [], aceptadas: []);

  final List<Solicitud> pendientes;
  final List<Solicitud> aceptadas;
}

/// Buscar match y solicitudes (`/api/match` en la API de cuentas).
///
/// Usa el mismo cliente HTTP que [CuentasService], así que en las pruebas la
/// API falsa también responde aquí.
abstract final class MatchService {
  static const _espera = Duration(seconds: 10);
  static const _sinConexion =
      'No se pudo conectar con el servidor. Intenta de nuevo.';

  static http.Client get _cliente => CuentasService.cliente;

  static Uri _uri(String ruta, [Map<String, String>? query]) =>
      Uri.parse('${ApiConfig.cuentasUrlBase}/api/match$ruta')
          .replace(queryParameters: query);

  static Map<String, String> get _encabezados => {
        'Content-Type': 'application/json; charset=utf-8',
        if (SesionActual.valor != null)
          'Authorization': 'Bearer ${SesionActual.valor!.token}',
      };

  /// Perfiles que todavía no has calificado (nunca el tuyo). Vienen **sin**
  /// Instagram: `Profile.instagram` queda vacío.
  static Future<List<Profile>> perfiles({
    ProfileKind? tipo,
    int? edadMin,
    int? edadMax,
    int limite = 20,
  }) async {
    final respuesta = await _enviar(() => _cliente.get(
          _uri('/perfiles', {
            if (tipo != null) 'tipo': tipo.name,
            if (edadMin != null) 'edadMin': '$edadMin',
            if (edadMax != null) 'edadMax': '$edadMax',
            'limite': '$limite',
          }),
          headers: _encabezados,
        ));

    _revisar(respuesta, 'No se pudieron cargar los perfiles.');

    return [
      for (final item in _json(respuesta) as List<dynamic>)
        _perfilDeTarjeta(item as Map<String, dynamic>),
    ];
  }

  /// Guarda el "sí" (like / super like) o el "no" (pasar).
  static Future<ResultadoCalificacion> calificar(
    String usuarioId,
    SwipeDecision decision,
  ) async {
    final respuesta = await _enviar(() => _cliente.post(
          _uri('/calificar'),
          headers: _encabezados,
          body: jsonEncode({
            'usuarioId': usuarioId,
            'si': decision != SwipeDecision.skip,
            'esSuperLike': decision == SwipeDecision.superLike,
          }),
        ));

    _revisar(respuesta, 'No se pudo guardar tu respuesta.');

    final json = _json(respuesta) as Map<String, dynamic>;
    final perfil = json['perfil'];
    return ResultadoCalificacion(
      match: json['match'] as bool? ?? false,
      perfil: perfil is Map<String, dynamic> ? Solicitud.fromJson(perfil) : null,
    );
  }

  /// Pendientes (te dieron "sí" y no has contestado) y aceptadas (match).
  static Future<Solicitudes> solicitudes() async {
    final respuesta = await _enviar(() => _cliente.get(
          _uri('/solicitudes'),
          headers: _encabezados,
        ));

    _revisar(respuesta, 'No se pudieron cargar tus solicitudes.');

    final json = _json(respuesta) as Map<String, dynamic>;
    List<Solicitud> lista(String clave) => [
          for (final item in json[clave] as List<dynamic>? ?? const [])
            Solicitud.fromJson(item as Map<String, dynamic>),
        ];

    return Solicitudes(
      pendientes: lista('pendientes'),
      aceptadas: lista('aceptadas'),
    );
  }

  /// El perfil completo de una solicitud, al abrirla.
  static Future<Solicitud> solicitud(String usuarioId) async {
    final respuesta = await _enviar(() => _cliente.get(
          _uri('/solicitudes/$usuarioId'),
          headers: _encabezados,
        ));

    _revisar(respuesta, 'No se pudo cargar el perfil.');
    return Solicitud.fromJson(_json(respuesta) as Map<String, dynamic>);
  }

  static Profile _perfilDeTarjeta(Map<String, dynamic> json) {
    final id = json['usuarioId'] as String;
    return Profile(
      id: id,
      name: json['nombre'] as String? ?? '',
      age: json['edad'] as int? ?? 0,
      kind: tipoDesdeTexto(json['tipo'] as String?),
      breed: json['raza'] as String? ?? '',
      distanceKm: 0,
      about: json['descripcion'] as String? ?? '',
      tags: [
        for (final i in json['intereses'] as List<dynamic>? ?? const [])
          i as String,
      ],
      // La API no lo manda hasta que haya match.
      instagram: '',
      photoUrl: FotosService.urlPrincipal(id),
      city: json['ciudad'] as String? ?? '',
    );
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
      final cuerpo = utf8.decode(respuesta.bodyBytes).trim();
      throw ApiException(
        cuerpo.isEmpty || cuerpo.startsWith('{') ? porDefecto : cuerpo,
      );
    }
  }

  static Object? _json(http.Response respuesta) =>
      jsonDecode(utf8.decode(respuesta.bodyBytes));
}
