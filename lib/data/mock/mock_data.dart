<<<<<<< HEAD
=======
import '../models/like.dart';
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
import '../models/profile.dart';

/// Datos de ejemplo que quedan mientras la API no los devuelve.
///
/// Los perfiles para buscar match, las solicitudes y los datos del usuario ya
/// vienen del servidor: aqui solo quedan las listas de opciones fijas.
abstract final class MockData {
<<<<<<< HEAD
  /// Filtros de la pantalla de buscar match. Solo mascotas.
  static const List<String> exploreFilters = [
    'Todos',
    'Perros',
    'Gatos',
    'Otros',
  ];
=======
  static const List<Profile> profiles = [
    Profile(
      id: 'max',
      name: 'Max',
      age: 3,
      kind: ProfileKind.perro,
      breed: 'Golden Retriever',
      distanceKm: 2,
      about:
          'Amo correr en la playa y perseguir pelotas. Busco amigos para pasear los domingos.',
      tags: ['Juguetón', 'Ama la playa', 'Paseos'],
      instagram: 'https://www.instagram.com/upamatch.max',
      isVerified: true,
    ),
    Profile(
      id: 'luna',
      name: 'Luna',
      age: 2,
      kind: ProfileKind.perro,
      breed: 'Husky Siberiano',
      distanceKm: 4,
      about:
          'Energía infinita. Busco con quién correr en el parque por las mañanas.',
      tags: ['Activa', 'Corredora', 'Sociable'],
      instagram: 'https://www.instagram.com/upamatch.luna',
      isVerified: true,
    ),
    Profile(
      id: 'sofia',
      name: 'Sofía',
      age: 26,
      kind: ProfileKind.persona,
      breed: 'Veterinaria',
      distanceKm: 3,
      about:
          'Amo a los animales y los fines de semana salgo a caminar con mi perrita Coco.',
      tags: ['Senderismo', 'Café', 'Perros'],
      instagram: 'https://www.instagram.com/upamatch.sofia',
    ),
    Profile(
      id: 'coco',
      name: 'Coco',
      age: 4,
      kind: ProfileKind.gato,
      breed: 'Siamés',
      distanceKm: 1,
      about: 'Experto en siestas al sol. Curioso, pero a mi ritmo.',
      tags: ['Tranquilo', 'Siestas', 'Curioso'],
      instagram: 'https://www.instagram.com/upamatch.coco',
    ),
    Profile(
      id: 'rocky',
      name: 'Rocky',
      age: 5,
      kind: ProfileKind.perro,
      breed: 'Bulldog Francés',
      distanceKm: 6,
      about: 'Pequeño pero con mucha personalidad. Me encantan las croquetas.',
      tags: ['Glotón', 'Cariñoso', 'Paseos cortos'],
      instagram: 'https://www.instagram.com/upamatch.rocky',
      isVerified: true,
    ),
    Profile(
      id: 'diego',
      name: 'Diego',
      age: 29,
      kind: ProfileKind.persona,
      breed: 'Diseñador',
      distanceKm: 8,
      about: 'Tengo dos gatos y siempre ando buscando cafés pet friendly.',
      tags: ['Gatos', 'Diseño', 'Cafés'],
      instagram: 'https://www.instagram.com/upamatch.diego',
    ),
    Profile(
      id: 'nina',
      name: 'Nina',
      age: 1,
      kind: ProfileKind.gato,
      breed: 'Persa',
      distanceKm: 5,
      about: 'Peluda, elegante y un poco dramática. Busco amigos tranquilos.',
      tags: ['Elegante', 'Casera', 'Mimos'],
      instagram: 'https://www.instagram.com/upamatch.nina',
    ),
  ];

  static Profile? profileById(String id) {
    for (final profile in profiles) {
      if (profile.id == id) return profile;
    }
    return null;
  }

  /// Quienes dieron like a tu perfil (pestaña "Likes"). Si les das like de
  /// vuelta en Explorar, es match.
  static const List<Like> likesReceived = [
    Like(profileId: 'luna', time: 'Hace 5 min', isSuperLike: true),
    Like(profileId: 'sofia', time: 'Hace 1 h'),
    Like(profileId: 'nina', time: 'Ayer'),
  ];

  static bool likedYou(String profileId) =>
      likesReceived.any((like) => like.profileId == profileId);

  /// Matches que ya tenías antes de abrir la app (pestaña Likes → Mis matches).
  static const List<String> matchesIniciales = ['rocky'];

  /// Perfil de quien usa la app (pantalla "Perfil").
  static const Profile currentUser = Profile(
    id: 'max',
    name: 'Max',
    age: 3,
    kind: ProfileKind.perro,
    breed: 'Golden Retriever',
    distanceKm: 0,
    about:
        'Amo correr en la playa y perseguir pelotas. Busco amigos para pasear los domingos.',
    tags: ['Juguetón', 'Ama la playa', 'Paseos', 'Amistad'],
    instagram: 'https://www.instagram.com/upamatch.max',
    isVerified: true,
  );

  static const String currentUserCity = 'Aguascalientes';

  /// Contadores de la pantalla "Perfil".
  static const List<({String label, String value})> profileStats = [
    (label: 'Likes', value: '128'),
    (label: 'Matches', value: '24'),
    (label: 'Chats', value: '8'),
  ];

  static const List<NearbyProfile> nearby = [
    NearbyProfile(id: 'luna', name: 'Luna'),
    NearbyProfile(id: 'sofia', name: 'Sofía'),
    NearbyProfile(id: 'rocky', name: 'Rocky'),
    NearbyProfile(id: 'coco', name: 'Coco'),
    NearbyProfile(id: 'diego', name: 'Diego'),
  ];

  /// Píldoras de Explorar y el tipo de perfil que muestra cada una
  /// (`null` = todos).
  static const Map<String, ProfileKind?> exploreFilters = {
    'Todos': null,
    'Personas': ProfileKind.persona,
    'Perros': ProfileKind.perro,
    'Gatos': ProfileKind.gato,
  };
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6

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
