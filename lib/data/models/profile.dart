/// Tipo de mascota. La app es solo para mascotas: no hay perfiles de personas.
enum ProfileKind {
  perro('Perro', '\u{1F436}'),
  gato('Gato', '\u{1F431}'),
  otro('Otro', '\u{1F430}');

  const ProfileKind(this.label, this.emoji);

  final String label;
  final String emoji;

  /// Convierte el texto que manda la API ("perro") al valor del enum.
  static ProfileKind desdeTexto(String? texto) => values.firstWhere(
        (k) => k.name == texto,
        orElse: () => ProfileKind.otro,
      );
}

/// Perfil de una mascota.
class Profile {
  const Profile({
    required this.id,
    required this.name,
    required this.age,
    required this.kind,
    required this.breed,
    required this.city,
    required this.distanceKm,
    required this.about,
    required this.tags,
<<<<<<< HEAD
    this.instagram,
=======
    required this.instagram,
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
    this.photoUrl,
    this.isVerified = false,
    this.city,
  });

  final String id;
  final String name;
  final int age;
  final ProfileKind kind;
  final String breed;
  final String city;
  final double distanceKm;
  final String about;
  final List<String> tags;

<<<<<<< HEAD
  /// Link al perfil de Instagram del dueño.
  ///
  /// La API solo lo manda cuando ya hay match: es la forma de contactarse,
  /// asi que antes del match llega nulo a proposito.
  final String? instagram;

=======
  /// Link completo de su Instagram: el contacto después del match es por ahí.
  final String instagram;

  /// Nula en el mockup: la tarjeta muestra el marcador "Pon aquí la foto".
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
  final String? photoUrl;
  final bool isVerified;

  /// Ciudad. Los perfiles que vienen de la API traen ciudad en lugar de
  /// distancia (todavía no se guarda la ubicación).
  final String? city;

  String get headline => '$name, $age';

<<<<<<< HEAD
  String get subtitle => '$breed · a ${distanceKm.toStringAsFixed(0)} km';

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'].toString(),
        name: json['nombre'] as String? ?? '',
        age: (json['edad'] as num?)?.toInt() ?? 0,
        kind: ProfileKind.desdeTexto(json['tipo'] as String?),
        breed: json['raza'] as String? ?? '',
        city: json['ciudad'] as String? ?? '',
        distanceKm: (json['distanciaKm'] as num?)?.toDouble() ?? 0,
        about: json['sobreMi'] as String? ?? '',
        tags: [
          for (final t in (json['intereses'] as List<dynamic>? ?? []))
            t.toString(),
        ],
        instagram: json['instagram'] as String?,
        isVerified: json['verificado'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'nombre': name,
        'edad': age,
        'tipo': kind.name,
        'raza': breed,
        'ciudad': city,
        'sobreMi': about,
        'intereses': tags,
        'instagram': instagram,
      };

  Profile copyWith({
    String? name,
    int? age,
    ProfileKind? kind,
    String? breed,
    String? city,
    String? about,
    List<String>? tags,
    String? instagram,
  }) =>
      Profile(
        id: id,
        name: name ?? this.name,
        age: age ?? this.age,
        kind: kind ?? this.kind,
        breed: breed ?? this.breed,
        city: city ?? this.city,
        distanceKm: distanceKm,
        about: about ?? this.about,
        tags: tags ?? this.tags,
        instagram: instagram ?? this.instagram,
        photoUrl: photoUrl,
        isVerified: isVerified,
      );
=======
  String get subtitle => city == null
      ? '$breed \u00B7 a ${distanceKm.toStringAsFixed(0)} km'
      : [breed, city!].where((s) => s.isNotEmpty).join(' \u00B7 ');
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
}

/// Perfil compacto de las filas de avatares.
class NearbyProfile {
  const NearbyProfile({required this.id, required this.name, this.photoUrl});

  final String id;
  final String name;
  final String? photoUrl;
}
