/// Conversación de la pantalla de Chats.
///
/// TODO(backend): mapear desde el API con `Conversation.fromJson`.
class Conversation {
  const Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    this.unread = 0,
    this.online = false,
    this.photoUrl,
  });

  final String id;
  final String name;
  final String lastMessage;

  /// Texto ya formateado ("14:32", "Ayer", "Lun").
  final String time;
  final int unread;
  final bool online;
  final String? photoUrl;

  bool get hasUnread => unread > 0;
}
