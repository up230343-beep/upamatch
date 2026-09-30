import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upamatch/data/api/cuentas_service.dart';
import 'package:upamatch/data/mis_solicitudes.dart';
import 'package:upamatch/data/session/sesion.dart';

/// Cuenta que existe en la API falsa.
const correoValido = 'max@upamatch.mx';
const contrasenaValida = 'secreta123';

/// Correo que la API falsa dice que ya está registrado.
const correoRegistrado = 'ya@upamatch.mx';

const sesionConPerfil = Sesion(
  token: 'token-de-prueba',
  usuarioId: 'u-max',
  correo: correoValido,
  tienePerfil: true,
);

/// Perfil que devuelve `GET /api/perfil`.
Map<String, dynamic> perfilMax = _perfilInicial();

Map<String, dynamic> _perfilInicial() => {
      'nombre': 'Max',
      'edad': 3,
      'tipo': 'perro',
      'raza': 'Golden Retriever',
      'ciudad': 'Aguascalientes',
      'descripcion': 'Amo correr en la playa.',
      'intereses': ['Paseos', 'Ama la playa'],
      'instagram': 'https://www.instagram.com/max.golden',
    };

http.Response _texto(String cuerpo, int codigo) => http.Response.bytes(
      utf8.encode(cuerpo),
      codigo,
      headers: {'content-type': 'text/plain; charset=utf-8'},
    );

http.Response _json(Object? cuerpo) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

// ---------------------------------------------------------------------------
// Buscar match y solicitudes (`/api/match`)
// ---------------------------------------------------------------------------

Map<String, dynamic> _mascota(
  String id,
  String nombre,
  int edad,
  String tipo,
  String raza, {
  List<String> intereses = const ['Paseos'],
}) =>
    {
      'usuarioId': id,
      'nombre': nombre,
      'edad': edad,
      'tipo': tipo,
      'raza': raza,
      'ciudad': 'Aguascalientes',
      'descripcion': 'Hola, soy $nombre.',
      'intereses': intereses,
      'instagram': 'https://www.instagram.com/upamatch.${nombre.toLowerCase()}',
    };

/// Los demás usuarios, en el orden en que salen al buscar match. `u-max` es
/// quien usa la app y nunca debe salir.
final List<Map<String, dynamic>> mascotasFalsas = [
  _mascota('u-max', 'Max', 3, 'perro', 'Golden Retriever'),
  _mascota('u-luna', 'Luna', 2, 'perro', 'Husky Siberiano'),
  _mascota('u-sofia', 'Sofia', 26, 'persona', 'Veterinaria'),
  _mascota('u-coco', 'Coco', 4, 'gato', 'Siamés'),
  _mascota('u-nina', 'Nina', 1, 'gato', 'Persa'),
  _mascota('u-rocky', 'Rocky', 5, 'perro', 'Bulldog Francés'),
];

/// Quienes le dieron "sí" a Max (true = super like).
final Map<String, bool> _leDieronSi = {};

/// Lo que Max ya calificó: id → "sí" (true) o "no" (false).
final Map<String, bool> calificacionesFalsas = {};

/// Estado inicial: Luna (super like) y Nina le dieron "sí" a Max y no ha
/// contestado; con Rocky ya es match.
void reiniciarMatchFalso() {
  _leDieronSi
    ..clear()
    ..addAll({'u-luna': true, 'u-nina': false, 'u-rocky': false});
  calificacionesFalsas
    ..clear()
    ..addAll({'u-rocky': true});
}

Map<String, dynamic> _sinInstagram(Map<String, dynamic> m) =>
    {...m}..remove('instagram');

Map<String, dynamic> _solicitud(Map<String, dynamic> m) {
  final id = m['usuarioId'] as String;
  final aceptada = calificacionesFalsas[id] == true;
  return {
    ..._sinInstagram(m),
    'estado': aceptada ? 'aceptada' : 'pendiente',
    'esSuperLike': _leDieronSi[id] ?? false,
    'fecha': DateTime.now()
        .toUtc()
        .subtract(const Duration(minutes: 5))
        .toIso8601String(),
    // Igual que la API: el Instagram solo va si ya hay match.
    if (aceptada) 'instagram': m['instagram'],
  };
}

Map<String, dynamic>? _mascotaPorId(String id) {
  for (final m in mascotasFalsas) {
    if (m['usuarioId'] == id) return m;
  }
  return null;
}

http.Response? _responderMatch(http.Request peticion, String ruta) {
  const yo = 'u-max';

  if (peticion.method == 'GET' && ruta == '/api/match/perfiles') {
    final tipo = peticion.url.queryParameters['tipo'];
    return _json([
      for (final m in mascotasFalsas)
        if (m['usuarioId'] != yo &&
            !calificacionesFalsas.containsKey(m['usuarioId']) &&
            (tipo == null || m['tipo'] == tipo))
          _sinInstagram(m),
    ]);
  }

  if (peticion.method == 'POST' && ruta == '/api/match/calificar') {
    final datos = jsonDecode(peticion.body) as Map<String, dynamic>;
    final id = datos['usuarioId'] as String;
    final otro = _mascotaPorId(id);
    if (otro == null) return _texto('Ese perfil ya no existe.', 404);
    calificacionesFalsas.putIfAbsent(id, () => datos['si'] as bool);
    final match = calificacionesFalsas[id] == true && _leDieronSi.containsKey(id);
    return _json({'match': match, if (match) 'perfil': _solicitud(otro)});
  }

  if (peticion.method == 'GET' && ruta == '/api/match/solicitudes') {
    final vigentes = [
      for (final id in _leDieronSi.keys)
        if (calificacionesFalsas[id] != false) ?_mascotaPorId(id),
    ].map(_solicitud).toList();
    return _json({
      'pendientes': [
        for (final s in vigentes)
          if (s['estado'] == 'pendiente') s,
      ],
      'aceptadas': [
        for (final s in vigentes)
          if (s['estado'] == 'aceptada') s,
      ],
    });
  }

  if (peticion.method == 'GET' && ruta.startsWith('/api/match/solicitudes/')) {
    final id = ruta.split('/').last;
    final otro = _mascotaPorId(id);
    if (otro == null ||
        !_leDieronSi.containsKey(id) ||
        calificacionesFalsas[id] == false) {
      return _texto('Esa solicitud ya no existe.', 404);
    }
    return _json(_solicitud(otro));
  }

  return null;
}

/// Imita a `backend/UpaMatch.Api` lo justo para las pantallas.
final _apiFalsa = MockClient((peticion) async {
  final ruta = peticion.url.path;
  if (ruta.startsWith('/api/match')) {
    return _responderMatch(peticion, ruta) ?? _texto('No encontrado', 404);
  }
  final datos = peticion.body.isEmpty
      ? const <String, dynamic>{}
      : jsonDecode(peticion.body) as Map<String, dynamic>;

  switch ((peticion.method, ruta)) {
    case ('POST', '/api/auth/login'):
      if (datos['correo'] == correoValido &&
          datos['contrasena'] == contrasenaValida) {
        return _json({
          'token': 'token-de-prueba',
          'usuarioId': 'u-max',
          'correo': correoValido,
          'tienePerfil': true,
        });
      }
      return _texto('Correo o contraseña incorrectos.', 401);

    case ('POST', '/api/auth/registro'):
      if (datos['correo'] == correoRegistrado) {
        return _texto('Ese correo ya está registrado. Inicia sesión.', 409);
      }
      return _json({
        'token': 'token-nuevo',
        'usuarioId': 'u-nuevo',
        'correo': datos['correo'],
        'tienePerfil': false,
      });

    case ('GET', '/api/auth/yo'):
      return _json({'usuarioId': 'u-max', 'correo': correoValido});

    case ('GET', '/api/perfil'):
      return _json(perfilMax);

    case ('PUT', '/api/perfil'):
      perfilMax = {
        ...datos,
        'instagram': datos['instagram'] == null
            ? null
            : 'https://www.instagram.com/'
                '${(datos['instagram'] as String).replaceFirst('@', '')}',
      };
      return _json(perfilMax);
  }
  return _texto('No encontrado', 404);
});

/// Deja el almacenamiento vacío, la API falsa conectada y, si [conSesion],
/// una sesión ya iniciada (como si el usuario hubiera entrado antes).
Future<void> prepararApiFalsa({bool conSesion = true}) async {
  SharedPreferences.setMockInitialValues({});
  CuentasService.cliente = _apiFalsa;
  perfilMax = _perfilInicial();
  MisSolicitudes.instancia.reiniciar();
  reiniciarMatchFalso();
  if (conSesion) {
    await SesionActual.guardar(sesionConPerfil);
  } else {
    await SesionActual.cerrar();
  }
}

/// El mockup está hecho para un iPhone 14 (390 x 844).
void usarPantallaDeTelefono(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
