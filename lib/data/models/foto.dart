/// Una foto del perfil, tal como la devuelve la API.
class Foto {
  const Foto({required this.nombre, required this.url});

  /// Casilla que ocupa: `principal`, `foto1`, `foto2`, `foto3` o `foto4`.
  final String nombre;

  /// Dirección para mostrarla; se usa directo en un `Image.network`.
  final String url;

  factory Foto.fromJson(Map<String, dynamic> json) => Foto(
        nombre: json['nombre'] as String,
        url: json['url'] as String,
      );

  /// `true` si es la foto que se ve en la tarjeta de Explorar.
  bool get esPrincipal => nombre == 'principal';
}
