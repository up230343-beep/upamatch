import '../../core/instagram.dart';
import '../api/fotos_service.dart';
import 'profile.dart';

/// En qué va una solicitud.
enum EstadoSolicitud {
  /// Te dio "sí" y todavía no contestas.
  pendiente,

  /// Los dos se dieron "sí": es match.
  aceptada,
}

/// Una solicitud: alguien te dio "sí". Es lo que devuelve
/// `GET /api/match/solicitudes` (y `/api/match/solicitudes/{id}`).
///
/// [instagram] solo llega cuando está [EstadoSolicitud.aceptada]: la API ni lo
/// manda en las pendientes.
class Solicitud {
  const Solicitud({
    required this.usuarioId,
    required this.nombre,
    required this.edad,
    required this.tipo,
    required this.raza,
    required this.ciudad,
    required this.descripcion,
    required this.intereses,
    required this.estado,
    required this.fecha,
    this.esSuperLike = false,
    this.instagram,
  });

  final String usuarioId;
  final String nombre;
  final int edad;
  final ProfileKind tipo;
  final String raza;
  final String ciudad;
  final String descripcion;
  final List<String> intereses;
  final EstadoSolicitud estado;

  /// Pendiente: cuándo te dio "sí". Aceptada: cuándo se hizo el match.
  final DateTime fecha;
  final bool esSuperLike;

  /// Link completo de Instagram, o `null` si todavía no hay match.
  final String? instagram;

  bool get aceptada => estado == EstadoSolicitud.aceptada;

  String get titulo => '$nombre, $edad';

  /// "Golden Retriever · Aguascalientes", o solo la ciudad si no hay raza.
  String get subtitulo =>
      [raza, ciudad].where((s) => s.isNotEmpty).join(' · ');

  /// "@usuario", o `null` si no hay match.
  String? get instagramUsuario =>
      instagram == null ? null : Instagram.usuario(instagram!);

  /// Foto principal (de la API de fotos).
  String get fotoUrl => FotosService.urlPrincipal(usuarioId);

  /// "Hace 5 min", "Ayer"...
  String get hace => tiempoRelativo(fecha);

  factory Solicitud.fromJson(Map<String, dynamic> json) => Solicitud(
        usuarioId: json['usuarioId'] as String,
        nombre: json['nombre'] as String? ?? '',
        edad: json['edad'] as int? ?? 0,
        tipo: tipoDesdeTexto(json['tipo'] as String?),
        raza: json['raza'] as String? ?? '',
        ciudad: json['ciudad'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        intereses: [
          for (final i in json['intereses'] as List<dynamic>? ?? const [])
            i as String,
        ],
        estado: json['estado'] == 'aceptada'
            ? EstadoSolicitud.aceptada
            : EstadoSolicitud.pendiente,
        fecha: fechaDeApi(json['fecha'] as String?),
        esSuperLike: json['esSuperLike'] as bool? ?? false,
        instagram: switch (json['instagram']) {
          final String link when link.isNotEmpty => link,
          _ => null,
        },
      );

  /// Para reutilizar las pantallas que trabajan con [Profile] (tarjeta,
  /// diálogo de match).
  Profile toProfile() => Profile(
        id: usuarioId,
        name: nombre,
        age: edad,
        kind: tipo,
        breed: raza,
        distanceKm: 0,
        about: descripcion,
        tags: intereses,
        instagram: instagram ?? '',
        photoUrl: fotoUrl,
        city: ciudad,
      );
}

/// `persona`, `perro`, `gato` u `otro`, como los guarda la API.
ProfileKind tipoDesdeTexto(String? tipo) => ProfileKind.values.firstWhere(
      (k) => k.name == tipo,
      orElse: () => ProfileKind.otro,
    );

/// La API guarda las fechas en UTC pero a veces las manda sin la "Z": se leen
/// siempre como UTC.
DateTime fechaDeApi(String? texto) {
  final fecha = texto == null ? null : DateTime.tryParse(texto);
  if (fecha == null) return DateTime.now().toUtc();
  if (fecha.isUtc) return fecha;
  return DateTime.utc(
    fecha.year,
    fecha.month,
    fecha.day,
    fecha.hour,
    fecha.minute,
    fecha.second,
    fecha.millisecond,
    fecha.microsecond,
  );
}

/// "Justo ahora", "Hace 5 min", "Hace 3 h", "Ayer", "Hace 4 días".
String tiempoRelativo(DateTime fecha, {DateTime? ahora}) {
  final diferencia = (ahora ?? DateTime.now()).difference(fecha);
  if (diferencia.inMinutes < 1) return 'Justo ahora';
  if (diferencia.inMinutes < 60) return 'Hace ${diferencia.inMinutes} min';
  if (diferencia.inHours < 24) return 'Hace ${diferencia.inHours} h';
  if (diferencia.inDays < 2) return 'Ayer';
  return 'Hace ${diferencia.inDays} días';
}
