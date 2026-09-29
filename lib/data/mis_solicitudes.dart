import 'package:flutter/foundation.dart';

import 'api/fotos_service.dart' show ApiException;
import 'api/match_service.dart';
import 'models/solicitud.dart';

/// Tus solicitudes, compartidas entre Buscar match (donde se completan los
/// matches), la pestaña de solicitudes y el globito de la barra inferior.
///
/// Los datos salen de la API (`GET /api/match/solicitudes`).
class MisSolicitudes extends ChangeNotifier {
  MisSolicitudes._();

  static final MisSolicitudes instancia = MisSolicitudes._();

  List<Solicitud> _pendientes = const [];
  List<Solicitud> _aceptadas = const [];
  bool _cargando = false;
  bool _cargado = false;
  String? _error;

  /// Te dieron "sí" y no has contestado. De la más nueva a la más vieja.
  List<Solicitud> get pendientes => _pendientes;

  /// Ya son match (con Instagram). De la más nueva a la más vieja.
  List<Solicitud> get aceptadas => _aceptadas;

  bool get cargando => _cargando;

  /// `true` después de la primera carga que salió bien.
  bool get cargado => _cargado;

  /// Mensaje si la última carga falló.
  String? get error => _error;

  /// Pide las dos listas a la API.
  Future<void> cargar() async {
    if (_cargando) return;
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      final respuesta = await MatchService.solicitudes();
      _pendientes = respuesta.pendientes;
      _aceptadas = respuesta.aceptadas;
      _cargado = true;
    } on ApiException catch (e) {
      _error = e.mensaje;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Se hizo match con [solicitud] (que ya trae el Instagram): pasa de
  /// pendiente a aceptada.
  void aceptada(Solicitud solicitud) {
    _pendientes = [
      for (final s in _pendientes)
        if (s.usuarioId != solicitud.usuarioId) s,
    ];
    _aceptadas = [
      solicitud,
      for (final s in _aceptadas)
        if (s.usuarioId != solicitud.usuarioId) s,
    ];
    notifyListeners();
  }

  /// Contestaste a [usuarioId] sin que fuera match (le diste "no"): sale de
  /// pendientes.
  void contestada(String usuarioId) {
    final antes = _pendientes.length;
    _pendientes = [
      for (final s in _pendientes)
        if (s.usuarioId != usuarioId) s,
    ];
    if (_pendientes.length != antes) notifyListeners();
  }

  /// Vacía todo (al cerrar sesión y en las pruebas).
  void reiniciar() {
    _pendientes = const [];
    _aceptadas = const [];
    _cargando = false;
    _cargado = false;
    _error = null;
    notifyListeners();
  }
}
