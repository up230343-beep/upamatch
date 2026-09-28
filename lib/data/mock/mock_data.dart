import '../models/conversation.dart';
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
  ];

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

  static const List<String> exploreFilters = [
    'Todos',
    'Personas',
    'Perros',
    'Gatos',
  ];

  static const List<String> lookingForOptions = [
    'Amor',
    'Amistad',
    'Paseos',
    'Jugar',
  ];
}
