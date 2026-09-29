import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:upamatch/features/chats/chat_detail_screen.dart';
import 'package:upamatch/features/onboarding/create_account_screen.dart';
import 'package:upamatch/features/explore/widgets/swipe_actions.dart';
import 'package:upamatch/features/profile_detail/profile_detail_screen.dart';
import 'package:upamatch/features/shell/main_shell.dart';
import 'package:upamatch/features/shell/widgets/main_bottom_nav.dart';
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

  testWidgets('la barra inferior abre Chats', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chat_bubble_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Nuevos matches'), findsOneWidget);
    expect(find.text('Mensajes'), findsOneWidget);
    expect(find.text('¿Vamos al parque el domingo?'), findsOneWidget);
  });

  testWidgets('la búsqueda de Chats filtra las conversaciones', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(const MaterialApp(home: MainShell()));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chat_bubble_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'parque');
    await tester.pumpAndSettle();

    expect(find.text('¿Vamos al parque el domingo?'), findsOneWidget);
    expect(find.text('Nos vemos en la plaza a las 6'), findsNothing);
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

  testWidgets('tocar una conversación abre el chat y se puede enviar', (
    tester,
  ) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(
      MaterialApp(initialRoute: AppRoutes.home, routes: AppRoutes.routes),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.chat_bubble_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Luna'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatDetailScreen), findsOneWidget);
    expect(find.text('Luna también es muy juguetona'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'El domingo a las 5');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('El domingo a las 5'), findsOneWidget);
  });

  group('explorar, match, likes y filtros', () {
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

    testWidgets('pasar muestra el siguiente perfil', (tester) async {
      await pumpShell(tester);
      expect(find.text('Max, 3'), findsOneWidget);

      await tester.tap(swipeButton(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Max, 3'), findsNothing);
      expect(find.text('Luna, 2'), findsOneWidget);
    });

    testWidgets('like a quien ya te dio like muestra el match', (tester) async {
      await pumpShell(tester);

      // Max no te dio like: no hay match.
      await tester.tap(swipeButton(Icons.favorite_rounded));
      await tester.pumpAndSettle();
      expect(find.text('¡Es un match!'), findsNothing);

      // Luna sí.
      await tester.tap(swipeButton(Icons.favorite_rounded));
      await tester.pumpAndSettle();
      expect(find.text('¡Es un match!'), findsOneWidget);

      await tester.tap(find.text('Seguir explorando'));
      await tester.pumpAndSettle();
      expect(find.text('¡Es un match!'), findsNothing);
      expect(find.text('Sofía, 26'), findsOneWidget);
    });

    testWidgets('tocar la tarjeta abre el detalle del perfil', (tester) async {
      await pumpShell(tester);

      await tester.tap(find.text('Max, 3'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileDetailScreen), findsOneWidget);
      expect(find.text('Sobre mí'), findsOneWidget);
      expect(find.text('Intereses'), findsOneWidget);
    });

    testWidgets('la pestaña Likes lista a quienes te dieron like',
        (tester) async {
      await pumpShell(tester);

      await tester.tap(find.descendant(
        of: find.byType(MainBottomNav),
        matching: find.text('Likes'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('A 3 perfiles les gustas'), findsOneWidget);
      expect(find.text('Luna, 2'), findsOneWidget);
      expect(find.text('Sofía, 26'), findsOneWidget);
      expect(find.text('Nina, 1'), findsOneWidget);
    });

    testWidgets('dar like desde Likes hace match y lo quita de la lista',
        (tester) async {
      await pumpShell(tester);

      await tester.tap(find.descendant(
        of: find.byType(MainBottomNav),
        matching: find.text('Likes'),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sofía, 26'));
      await tester.pumpAndSettle();

      await tester.tap(swipeButton(Icons.favorite_rounded));
      await tester.pumpAndSettle();
      expect(find.text('¡Es un match!'), findsOneWidget);

      await tester.tap(find.text('Seguir explorando'));
      await tester.pumpAndSettle();
      expect(find.text('A 2 perfiles les gustas'), findsOneWidget);
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
