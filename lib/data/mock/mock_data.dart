import '../models/conversation.dart';
import '../models/like.dart';
import '../models/message.dart';
import '../models/profile.dart';

/// Contenido de ejemplo copiado del mockup de Figma.
///
/// TODO(backend): sustituir por la respuesta real del API. Ninguna pantalla
/// importa datos de otro sitio, así que basta con cambiar el origen de estos
/// valores.
abstract final class MockData {
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

  /// Matches todavía sin conversación (fila superior de "Chats").
  static const List<NearbyProfile> newMatches = [
    NearbyProfile(id: 'nina', name: 'Nina'),
    NearbyProfile(id: 'toby', name: 'Toby'),
    NearbyProfile(id: 'mia', name: 'Mía'),
    NearbyProfile(id: 'bruno', name: 'Bruno'),
  ];

  static const List<Conversation> conversations = [
    Conversation(
      id: 'luna',
      name: 'Luna',
      lastMessage: '¿Vamos al parque el domingo?',
      time: '14:32',
      unread: 2,
      online: true,
    ),
    Conversation(
      id: 'sofia',
      name: 'Sofía',
      lastMessage: 'A Coco le encantó la playa',
      time: '12:05',
      unread: 1,
    ),
    Conversation(
      id: 'rocky',
      name: 'Rocky',
      lastMessage: 'Te mando la foto del paseo',
      time: 'Ayer',
      online: true,
    ),
    Conversation(
      id: 'coco',
      name: 'Coco',
      lastMessage: 'Gracias por la recomendación del veterinario',
      time: 'Ayer',
    ),
    Conversation(
      id: 'diego',
      name: 'Diego',
      lastMessage: 'Nos vemos en la plaza a las 6',
      time: 'Lun',
    ),
  ];

  /// Historial de cada conversación, por `Conversation.id`.
  ///
  /// Las que no aparecen aquí muestran solo su último mensaje.
  static const Map<String, List<Message>> messages = {
    'luna': [
      Message(
        id: 'l1',
        text: '¡Hola! Vi que a Max le gusta la playa',
        time: '14:10',
        fromMe: false,
      ),
      Message(
        id: 'l2',
        text: 'Sí, le encanta. Vamos casi cada fin de semana',
        time: '14:12',
        fromMe: true,
      ),
      Message(
        id: 'l3',
        text: 'Luna también es muy juguetona',
        time: '14:30',
        fromMe: false,
      ),
      Message(
        id: 'l4',
        text: '¿Vamos al parque el domingo?',
        time: '14:32',
        fromMe: false,
      ),
    ],
  };

  /// Píldoras de Explorar y el tipo de perfil que muestra cada una
  /// (`null` = todos).
  static const Map<String, ProfileKind?> exploreFilters = {
    'Todos': null,
    'Personas': ProfileKind.persona,
    'Perros': ProfileKind.perro,
    'Gatos': ProfileKind.gato,
  };

  static const List<String> lookingForOptions = [
    'Amor',
    'Amistad',
    'Paseos',
    'Jugar',
  ];
}
