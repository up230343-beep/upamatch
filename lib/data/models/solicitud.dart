import 'profile.dart';

/// Una solicitud de match.
///
/// - **Pendiente**: esa mascota te dio "si" y tu todavia no contestas.
/// - **Aceptada**: los dos se dieron "si". Aqui ya se puede ver el Instagram
///   para contactarse; en las pendientes no.
class Solicitud {
  const Solicitud({required this.perfil, required this.aceptada});

  final Profile perfil;
  final bool aceptada;

  factory Solicitud.fromJson(Map<String, dynamic> json) => Solicitud(
        perfil: Profile.fromJson(json['perfil'] as Map<String, dynamic>),
        aceptada: json['aceptada'] as bool? ?? false,
      );
}
