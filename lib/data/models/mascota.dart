import 'profile.dart';

/// Datos de la mascota (o persona) de quien usa la app, tal como los guarda
/// la API de cuentas.
class Mascota {
  const Mascota({
    required this.nombre,
    required this.edad,
    required this.tipo,
    required this.raza,
    required this.ciudad,
    required this.descripcion,
    required this.intereses,
    this.instagram,
  });

  final String nombre;
  final int edad;
  final ProfileKind tipo;
  final String raza;
  final String ciudad;
  final String descripcion;
  final List<String> intereses;

  /// Link completo (`https://www.instagram.com/usuario`) o `null`.
  final String? instagram;

  String get titulo => '$nombre, $edad';

  /// "Golden Retriever · Aguascalientes", o solo la ciudad si no hay raza.
  String get subtitulo => [raza, ciudad].where((s) => s.isNotEmpty).join(' · ');

  /// "@usuario" a partir del link, para mostrarlo corto.
  String? get instagramUsuario {
    final link = instagram;
    if (link == null) return null;
    final partes = Uri.tryParse(link)?.pathSegments ?? const [];
    return partes.isEmpty ? link : '@${partes.first}';
  }

  factory Mascota.fromJson(Map<String, dynamic> json) => Mascota(
        nombre: json['nombre'] as String,
        edad: json['edad'] as int,
        tipo: ProfileKind.values.firstWhere(
          (k) => k.name == json['tipo'],
          orElse: () => ProfileKind.otro,
        ),
        raza: json['raza'] as String? ?? '',
        ciudad: json['ciudad'] as String? ?? '',
        descripcion: json['descripcion'] as String? ?? '',
        intereses: [
          for (final i in json['intereses'] as List<dynamic>? ?? const [])
            i as String,
        ],
        instagram: json['instagram'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'edad': edad,
        'tipo': tipo.name,
        'raza': raza,
        'ciudad': ciudad,
        'descripcion': descripcion,
        'intereses': intereses,
        'instagram': instagram,
      };
}
