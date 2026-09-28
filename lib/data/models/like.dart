/// Like recibido: alguien dio like a tu perfil (pestaña "Likes").
///
/// TODO(backend): mapear desde el API con `Like.fromJson`.
class Like {
  const Like({
    required this.profileId,
    required this.time,
    this.isSuperLike = false,
  });

  /// `Profile.id` de quien dio el like.
  final String profileId;

  /// Texto ya formateado ("Hace 5 min", "Ayer").
  final String time;
  final bool isSuperLike;
}
