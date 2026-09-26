/// Tipo de perfil que se puede crear o explorar.
enum ProfileKind {
  persona('Persona', '\u{1F469}'),
  perro('Perro', '\u{1F436}'),
  gato('Gato', '\u{1F431}'),
  otro('Otro', '\u{1F430}');

  const ProfileKind(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// Perfil mostrado en la tarjeta de "Explorar".
///
/// TODO(backend): mapear desde el JSON del API con `Profile.fromJson`.
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.kind,
    required this.breed,
    required this.distanceKm,
    required this.about,
    required this.tags,
    this.photoUrl,
    this.isVerified = false,
  });

  final String id;
  final String name;
  final int age;
  final ProfileKind kind;
  final String breed;
  final double distanceKm;
  final String about;
  final List<String> tags;

  /// Nula en el mockup: la tarjeta muestra el marcador "Pon aquí la foto".
  final String? photoUrl;
  final bool isVerified;

  String get headline => '$name, $age';

  String get subtitle =>
      '$breed \u00B7 a ${distanceKm.toStringAsFixed(0)} km';
}

/// Perfil compacto de la fila "Nuevos cerca de ti".
class NearbyProfile {
  const NearbyProfile({required this.id, required this.name, this.photoUrl});

  final String id;
  final String name;
  final String? photoUrl;
}
