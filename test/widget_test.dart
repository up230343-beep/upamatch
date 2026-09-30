import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:upamatch/features/onboarding/create_account_screen.dart';
import 'package:upamatch/features/explore/widgets/swipe_actions.dart';
import 'package:upamatch/features/profile_detail/profile_detail_screen.dart';
import 'package:upamatch/features/shell/main_shell.dart';
import 'package:upamatch/features/shell/widgets/main_bottom_nav.dart';
import 'package:upamatch/features/solicitudes/solicitud_detalle_screen.dart';
import 'package:upamatch/routes/app_routes.dart';

import 'helpers/api_falsa.dart';

/// El mockup está hecho para un iPhone 14 (390 x 844).
const Size _designSize = Size(390, 844);

void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  // Login y registro se prueban en cuentas_test.dart. Aquí se entra ya con
  // sesión iniciada.
  setUp(prepararApiFalsa);

  testWidgets('crear cuenta permite cambiar el tipo de perfil', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(const MaterialApp(home: CreateAccountScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Persona'), findsOneWidget);
    await tester.tap(find.text('Persona'));
    await tester.pumpAndSettle();

    expect(find.text('Persona'), findsOneWidget);
  });

  testWidgets('los filtros de explorar cambian de selección', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    expect(find.text('Todos'), findsOneWidget);

    await tester.tap(find.text('Perros'));
    await tester.pumpAndSettle();

    expect(find.text('Perros'), findsOneWidget);
  });

  testWidgets('la barra inferior abre Perfil', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.person_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Sobre mí'), findsOneWidget);
    expect(find.text('Intereses'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  group('buscar match, solicitudes y filtros', () {
    Future<void> pumpShell(WidgetTester tester) async {
      _usePhoneSurface(tester);
      await tester.pumpWidget(
        MaterialApp(initialRoute: AppRoutes.home, routes: AppRoutes.routes),
      );
      await tester.pumpAndSettle();
    }

    Finder swipeButton(IconData icon) => find.descendant(
          of: find.byType(SwipeActions),
          matching: find.byIcon(icon),
        );

    Future<void> abrirSolicitudes(WidgetTester tester) async {
      await tester.tap(find.descendant(
        of: find.byType(MainBottomNav),
        matching: find.text('Likes'),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('trae perfiles de la API y nunca el tuyo', (tester) async {
      await pumpShell(tester);

      expect(find.text('Luna, 2'), findsOneWidget);
      expect(find.text('Max, 3'), findsNothing);
    });

    testWidgets('pasar guarda el "no" y muestra el siguiente perfil',
        (tester) async {
      await pumpShell(tester);

      await tester.tap(swipeButton(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Luna, 2'), findsNothing);
      expect(find.text('Sofia, 26'), findsOneWidget);
      expect(calificacionesFalsas['u-luna'], isFalse);
    });

    testWidgets('avisa cuando ya no quedan perfiles', (tester) async {
      await pumpShell(tester);

      // Luna, Sofia, Coco y Nina (Rocky ya era match y no sale).
      for (var i = 0; i < 4; i++) {
        await tester.tap(swipeButton(Icons.close_rounded));
        await tester.pumpAndSettle();
      }

      expect(find.text('Ya no quedan perfiles por ver'), findsOneWidget);
      expect(find.byType(SwipeActions), findsNothing);
    });

    testWidgets('sí a quien ya te dio sí muestra el match con su Instagram',
        (tester) async {
      await pumpShell(tester);

      // Luna ya le había dado "sí" a Max.
      await tester.tap(swipeButton(Icons.favorite_rounded));
      await tester.pumpAndSettle();
      expect(find.text('¡Es un match!'), findsOneWidget);
      expect(find.textContaining('@upamatch.luna'), findsOneWidget);

      await tester.tap(find.text('Seguir explorando'));
      await tester.pumpAndSettle();
      expect(find.text('Sofia, 26'), findsOneWidget);

      // Sofia no: no hay match.
      await tester.tap(swipeButton(Icons.favorite_rounded));
      await tester.pumpAndSettle();
      expect(find.text('¡Es un match!'), findsNothing);
      expect(find.text('Coco, 4'), findsOneWidget);
    });

    testWidgets('tocar la tarjeta abre el detalle del perfil', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Luna, 2'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileDetailScreen), findsOneWidget);
      expect(find.text('Sobre mí'), findsOneWidget);
      expect(find.text('Intereses'), findsOneWidget);
    });

    testWidgets('solicitudes pendientes y aceptadas', (tester) async {
      await pumpShell(tester);
      await abrirSolicitudes(tester);

      expect(find.text('Solicitudes'), findsOneWidget);
      expect(find.text('A 2 perfiles les gustas'), findsOneWidget);
      expect(find.text('Luna, 2'), findsOneWidget);
      expect(find.text('Nina, 1'), findsOneWidget);
      // En pendientes no hay Instagram.
      expect(find.textContaining('@upamatch'), findsNothing);

      await tester.tap(find.text('Aceptadas (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Rocky, 5'), findsOneWidget);
      expect(find.text('@upamatch.rocky'), findsOneWidget);
    });

    testWidgets('abrir una pendiente muestra el perfil completo sin Instagram',
        (tester) async {
      await pumpShell(tester);
      await abrirSolicitudes(tester);

      await tester.tap(find.text('Luna, 2'));
      await tester.pumpAndSettle();

      expect(find.byType(SolicitudDetalleScreen), findsOneWidget);
      expect(find.text('Husky Siberiano'), findsOneWidget);
      expect(find.text('Aguascalientes'), findsOneWidget);
      expect(find.text('Hola, soy Luna.'), findsOneWidget);
      expect(find.text('Paseos'), findsOneWidget);
      expect(find.text('Pendiente'), findsOneWidget);
      expect(find.textContaining('@upamatch.luna'), findsNothing);
      expect(
        find.text('Su Instagram aparece cuando los dos se den "sí".'),
        findsOneWidget,
      );
    });

    testWidgets('contestar sí a una pendiente la pasa a aceptadas',
        (tester) async {
      await pumpShell(tester);
      await abrirSolicitudes(tester);

      await tester.tap(find.text('Nina, 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sí'));
      await tester.pumpAndSettle();

      expect(find.text('¡Es un match!'), findsOneWidget);
      await tester.tap(find.text('Seguir explorando'));
      await tester.pumpAndSettle();

      expect(find.text('A 1 perfil le gustas'), findsOneWidget);
      await tester.tap(find.text('Aceptadas (2)'));
      await tester.pumpAndSettle();
      expect(find.text('@upamatch.nina'), findsOneWidget);
    });

    testWidgets('contestar no a una pendiente la quita', (tester) async {
      await pumpShell(tester);
      await abrirSolicitudes(tester);

      await tester.tap(find.text('Nina, 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.text('¡Es un match!'), findsNothing);
      expect(find.text('A 1 perfil le gustas'), findsOneWidget);
      expect(find.text('Nina, 1'), findsNothing);
    });

    testWidgets('abrir una aceptada muestra su Instagram', (tester) async {
      await pumpShell(tester);
      await abrirSolicitudes(tester);
      await tester.tap(find.text('Aceptadas (1)'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Rocky, 5'));
      await tester.pumpAndSettle();

      expect(find.byType(SolicitudDetalleScreen), findsOneWidget);
      expect(find.text('Match'), findsOneWidget);
      expect(find.text('@upamatch.rocky'), findsOneWidget);
      expect(find.text('Sí'), findsNothing);
    });

    testWidgets('la barra inferior ya no tiene Chats', (tester) async {
      await pumpShell(tester);

      Finder enBarra(String texto) => find.descendant(
            of: find.byType(MainBottomNav),
            matching: find.text(texto),
          );

      expect(find.byIcon(Icons.chat_bubble_rounded), findsNothing);
      expect(enBarra('Chats'), findsNothing);
      for (final pestana in ['Explorar', 'Likes', 'Perfil']) {
        expect(enBarra(pestana), findsOneWidget);
      }
    });

    testWidgets('los filtros se abren y se aplican', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.byIcon(Icons.tune_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Distancia máxima'), findsOneWidget);

      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('Distancia máxima'), findsNothing);
    });
  });
}
