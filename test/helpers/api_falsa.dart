import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upamatch/data/api/cuentas_service.dart';
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

http.Response _json(Object cuerpo) => http.Response.bytes(
      utf8.encode(jsonEncode(cuerpo)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

/// Imita a `backend/UpaMatch.Api` lo justo para las pantallas.
final _apiFalsa = MockClient((peticion) async {
  final ruta = peticion.url.path;
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
