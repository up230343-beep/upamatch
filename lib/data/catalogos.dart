/// Listas fijas que ofrece la app al llenar el perfil.
abstract final class Catalogos {
  /// Intereses sugeridos. Se pueden elegir hasta [interesesMax].
  static const List<String> intereses = [
    'Amor',
    'Amistad',
    'Paseos',
    'Jugar',
    'Correr',
    'Ama la playa',
    'Siestas',
    'Viajes',
    'Parques',
    'Mimos',
    'Nadar',
    'Café',
  ];

  /// Igual que `Reglas.InteresesMax` en la API.
  static const int interesesMax = 8;
}
