import 'package:flutter_test/flutter_test.dart';
import 'package:upamatch/data/api/match_service.dart';
import 'package:upamatch/data/models/profile.dart';
import 'package:upamatch/data/models/solicitud.dart';
import 'package:upamatch/data/models/swipe_decision.dart';

import 'helpers/api_falsa.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(prepararApiFalsa);

  group('MatchService', () {
    test('los perfiles para buscar match no traen Instagram ni el tuyo',
        () async {
      final perfiles = await MatchService.perfiles();

      expect(perfiles.map((p) => p.id), isNot(contains('u-max')));
      expect(perfiles.every((p) => p.instagram.isEmpty), isTrue);
      // Rocky ya estaba calificado.
      expect(perfiles.map((p) => p.id), isNot(contains('u-rocky')));
    });

    test('filtra por tipo', () async {
      final gatos = await MatchService.perfiles(tipo: ProfileKind.gato);
      expect(gatos.map((p) => p.name), ['Coco', 'Nina']);
    });

    test('un perfil calificado ya no vuelve a salir', () async {
      await MatchService.calificar('u-coco', SwipeDecision.skip);
      final perfiles = await MatchService.perfiles();
      expect(perfiles.map((p) => p.id), isNot(contains('u-coco')));
    });

    test('sí mutuo es match y trae el Instagram', () async {
      final resultado =
          await MatchService.calificar('u-luna', SwipeDecision.like);

      expect(resultado.match, isTrue);
      expect(resultado.perfil!.aceptada, isTrue);
      expect(resultado.perfil!.instagram,
          'https://www.instagram.com/upamatch.luna');
    });

    test('sí sin sí de vuelta no es match', () async {
      final resultado =
          await MatchService.calificar('u-coco', SwipeDecision.like);
      expect(resultado.match, isFalse);
      expect(resultado.perfil, isNull);
    });

    test('pendientes sin Instagram; aceptadas con Instagram', () async {
      final solicitudes = await MatchService.solicitudes();

      expect(solicitudes.pendientes.map((s) => s.nombre), ['Luna', 'Nina']);
      expect(solicitudes.pendientes.every((s) => s.instagram == null), isTrue);
      expect(solicitudes.aceptadas.single.nombre, 'Rocky');
      expect(solicitudes.aceptadas.single.instagramUsuario, '@upamatch.rocky');
    });
  });

  group('Solicitud', () {
    test('lee las fechas de la API como UTC', () {
      expect(fechaDeApi('2026-09-29T17:00:00').isUtc, isTrue);
      expect(fechaDeApi('2026-09-29T17:00:00Z').isUtc, isTrue);
    });

    test('tiempo relativo', () {
      final ahora = DateTime.utc(2026, 9, 29, 12);
      String hace(Duration d) => tiempoRelativo(ahora.subtract(d), ahora: ahora);

      expect(hace(const Duration(seconds: 20)), 'Justo ahora');
      expect(hace(const Duration(minutes: 5)), 'Hace 5 min');
      expect(hace(const Duration(hours: 3)), 'Hace 3 h');
      expect(hace(const Duration(hours: 30)), 'Ayer');
      expect(hace(const Duration(days: 4)), 'Hace 4 días');
    });
  });
}
