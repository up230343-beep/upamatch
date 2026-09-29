import '../models/profile.dart';

/// Datos de ejemplo que quedan mientras la API no los devuelve.
///
/// Los perfiles para buscar match, las solicitudes y los datos del usuario ya
/// vienen del servidor: aqui solo quedan las listas de opciones fijas.
abstract final class MockData {
  /// Filtros de la pantalla de buscar match. Solo mascotas.
  static const List<String> exploreFilters = [
    'Todos',
    'Perros',
    'Gatos',
    'Otros',
  ];

  /// Opciones de "¿Que buscas?" del registro y del perfil.
  static const List<String> lookingForOptions = [
    'Amistad',
    'Paseos',
    'Jugar',
    'Pareja',
  ];

  /// Perfil vacio que se usa mientras carga el del servidor.
  static const Profile perfilVacio = Profile(
    id: '',
    name: '',
    age: 0,
    kind: ProfileKind.perro,
    breed: '',
    city: '',
    distanceKm: 0,
    about: '',
    tags: [],
  );
}
