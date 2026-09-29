import 'package:flutter/foundation.dart';

import 'mock/mock_data.dart';
import 'models/profile.dart';

/// Tus matches. Los comparten Explorar (donde se hacen) y Likes (donde se
/// listan con el botón para abrir su Instagram).
///
/// TODO(backend): leerlos de la API (tabla Likes: A→B y B→A).
class MisMatches extends ChangeNotifier {
  MisMatches._();

  static final MisMatches instancia = MisMatches._();

  final List<String> _ids = [...MockData.matchesIniciales];

  /// Del más reciente al más viejo.
  List<Profile> get perfiles => [
        for (final id in _ids.reversed) ?MockData.profileById(id),
      ];

  bool contiene(String id) => _ids.contains(id);

  void agregar(Profile perfil) {
    if (contiene(perfil.id)) return;
    _ids.add(perfil.id);
    notifyListeners();
  }

  /// Regresa a los matches de ejemplo (para las pruebas).
  @visibleForTesting
  void reiniciar() {
    _ids
      ..clear()
      ..addAll(MockData.matchesIniciales);
    notifyListeners();
  }
}
