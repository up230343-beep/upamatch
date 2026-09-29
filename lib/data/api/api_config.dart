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
}
