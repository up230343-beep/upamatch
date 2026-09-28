/// Mensaje dentro de una conversación.
///
/// TODO(backend): mapear desde el API con `Message.fromJson`.
class Message {
  const Message({
    required this.id,
    required this.text,
    required this.time,
    required this.fromMe,
  });

  final String id;
  final String text;

  /// Texto ya formateado ("14:32").
  final String time;

  /// `true` si lo envió quien usa la app (burbuja morada a la derecha).
  final bool fromMe;
}
