import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

import '../models/foto.dart';
import 'api_config.dart';

/// Error de la API con el mensaje que manda el servidor, para poder
/// enseñárselo al usuario tal cual ("Ya tienes 5 fotos", etc.).
class ApiException implements Exception {
  ApiException(this.mensaje);

  final String mensaje;

  @override
  String toString() => mensaje;
}

/// Habla con la API de fotos. Es lo único de la app que sabe de HTTP.
abstract final class FotosService {
  static const int maxFotos = 5;

  static Uri _uri(String ruta) => Uri.parse('${ApiConfig.urlBase}/api/fotos$ruta');

  /// Dirección de la foto principal de un usuario, para pintarla sin tener
  /// que pedir antes la lista. Si no tiene foto, la API responde 404 y el
  /// widget se queda con su marcador.
  static String urlPrincipal(String usuarioId) =>
      '${ApiConfig.urlBase}/api/fotos/$usuarioId/principal';

  /// Igual que [urlPrincipal] pero forzando que se vuelva a descargar, para
  /// cuando se acaba de cambiar la foto.
  static String urlPrincipalFresca(String usuarioId, int version) =>
      '${urlPrincipal(usuarioId)}?v=$version';

  /// Las fotos que tiene el usuario, empezando por la principal.
  /// Si no tiene ninguna, devuelve una lista vacía.
  static Future<List<Foto>> listar(String usuarioId) async {
    final respuesta = await http.get(_uri('/$usuarioId'));

    if (respuesta.statusCode != 200) {
      throw ApiException('No se pudieron cargar las fotos.');
    }

    final lista = jsonDecode(respuesta.body) as List<dynamic>;

    return [
      for (final item in lista) Foto.fromJson(item as Map<String, dynamic>),
    ];
  }

  /// Sube una foto a la primera casilla libre.
  static Future<Foto> subir(String usuarioId, XFile archivo) =>
      _enviar(_uri('/$usuarioId'), archivo);

  /// Sube una foto a una casilla concreta. Si ya había una, la reemplaza:
  /// así es como se cambia una foto.
  static Future<Foto> reemplazar(
    String usuarioId,
    String nombreFoto,
    XFile archivo,
  ) =>
      _enviar(_uri('/$usuarioId/$nombreFoto'), archivo);

  /// Borra una foto del perfil.
  static Future<void> eliminar(String usuarioId, String nombreFoto) async {
    final respuesta = await http.delete(_uri('/$usuarioId/$nombreFoto'));

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensajeDe(respuesta, 'No se pudo eliminar la foto.'));
    }
  }

  /// Manda el archivo como `multipart/form-data`, que es lo que espera la API.
  static Future<Foto> _enviar(Uri destino, XFile archivo) async {
    final peticion = http.MultipartRequest('POST', destino);

    // Se leen los bytes (en vez de mandar la ruta) porque en la web no hay
    // rutas de archivo reales. Así funciona igual en Chrome y en el teléfono.
    peticion.files.add(http.MultipartFile.fromBytes(
      'archivo',
      await archivo.readAsBytes(),
      filename: archivo.name,
      contentType: _tipoDe(archivo),
    ));

    final respuesta = await http.Response.fromStream(await peticion.send());

    if (respuesta.statusCode != 200) {
      throw ApiException(_mensajeDe(respuesta, 'No se pudo subir la foto.'));
    }

    return Foto.fromJson(jsonDecode(respuesta.body) as Map<String, dynamic>);
  }

  /// La API solo acepta imágenes, así que hay que decirle de qué tipo es.
  static MediaType _tipoDe(XFile archivo) {
    final tipo = archivo.mimeType;

    if (tipo != null && tipo.startsWith('image/')) {
      return MediaType.parse(tipo);
    }

    // Si el sistema no lo dijo, se deduce de la extensión.
    final extension = archivo.name.split('.').last.toLowerCase();

    return MediaType('image', switch (extension) {
      'png' => 'png',
      'gif' => 'gif',
      'webp' => 'webp',
      _ => 'jpeg',
    });
  }

  /// Los errores de la API vienen en texto plano; si viene vacío se usa uno
  /// genérico para no enseñar una pantalla sin explicación.
  static String _mensajeDe(http.Response respuesta, String porDefecto) {
    final cuerpo = respuesta.body.trim();
    return cuerpo.isEmpty ? porDefecto : cuerpo;
  }
}
