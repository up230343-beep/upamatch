<<<<<<< HEAD
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Datos de conexión con la API.
///
/// La dirección se elige sola según dónde corra la app, así no hay que andar
/// cambiándola cada vez que se prueba en un lado o en otro.
abstract final class ApiConfig {
  /// Puerto en el que corre la API.
  static const String puerto = '5250';

  /// IP de la computadora que tiene corriendo la API.
  ///
  /// Solo se usa para probar en un **celular real**. Se ve con `ipconfig` en
  /// la computadora donde corre la API, en el renglón "IPv4".
  ///
  /// Hoy: Ethernet 192.168.1.2 · Wi-Fi 192.168.137.165
  /// (cambia cada vez que la computadora se reconecta a la red).
  static const String ipDeLaCompu = '192.168.1.2';

  /// Ponlo en `true` solo cuando se pruebe en un celular real conectado por
  /// cable o por la misma red Wi-Fi que la computadora.
  static const bool enCelularReal = false;

  /// La dirección de la API según dónde esté corriendo la app.
  static String get urlBase {
    // En el navegador, la API está en la misma computadora.
    if (kIsWeb) return 'http://localhost:$puerto';

    // En un celular real hay que ir por la red, con la IP de la computadora.
    if (enCelularReal) return 'http://$ipDeLaCompu:$puerto';

    // En el emulador de Android, 10.0.2.2 es como el emulador llama a la
    // computadora donde corre (su "localhost" es el propio emulador).
    if (Platform.isAndroid) return 'http://10.0.2.2:$puerto';

    // Windows, iOS y lo demás.
    return 'http://localhost:$puerto';
  }
=======
import '../session/sesion.dart';

/// Datos de conexión con las APIs.
///
/// Si cambias la dirección de una API, se cambia aquí y ya: ninguna pantalla
/// escribe la URL a mano.
///
/// - App en Chrome, en esta misma computadora: `http://localhost:<puerto>`
/// - Emulador de Android: `http://10.0.2.2:<puerto>` (para el emulador,
///   `localhost` es el propio teléfono, no la computadora)
/// - Teléfono real: `http://<ip-de-la-compu>:<puerto>` (se ve con `ipconfig`)
abstract final class ApiConfig {
  /// API de fotos (Azure).
  static const String urlBase = 'http://localhost:5250';

  /// API de cuentas y perfiles (`backend/UpaMatch.Api`).
  static const String cuentasUrlBase = 'http://localhost:5260';

  /// Usuario que inició sesión: de él se muestran y se suben las fotos.
  ///
  /// Solo se usa en pantallas que están detrás del login, así que siempre hay
  /// sesión.
  static String get usuarioId => SesionActual.valor?.usuarioId ?? '';
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
}
