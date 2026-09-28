/// Datos de conexión con la API de fotos.
///
/// Si cambias la dirección de la API, se cambia aquí y ya: ninguna pantalla
/// escribe la URL a mano.
abstract final class ApiConfig {
  /// Dirección de la API de fotos.
  ///
  /// - App en Chrome, en esta misma computadora: `http://localhost:5250`
  /// - Emulador de Android: `http://10.0.2.2:5250` (para el emulador,
  ///   `localhost` es el propio teléfono, no la computadora)
  /// - Teléfono real: `http://<ip-de-la-compu>:5250` (se ve con `ipconfig`)
  static const String urlBase = 'http://localhost:5250';

  /// Usuario del que se muestran y se suben las fotos.
  ///
  /// TODO(backend): cuando haya login de verdad, esto sale de la sesión
  /// guardada en lugar de estar fijo aquí.
  static const String usuarioId = 'max';
}
