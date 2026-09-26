import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:upamatch/features/onboarding/create_account_screen.dart';
import 'package:upamatch/features/shell/main_shell.dart';
import 'package:upamatch/main.dart';

/// El mockup está hecho para un iPhone 14 (390 x 844).
const Size _designSize = Size(390, 844);

void _usePhoneSurface(WidgetTester tester) {
  tester.view.physicalSize = _designSize;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  testWidgets('el login se dibuja con sus textos principales', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(const UpaMatchApp());

    expect(find.text('UpaMatch'), findsOneWidget);
    expect(find.text('Iniciar sesión'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
    expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
  });

  testWidgets('se navega de login a crear cuenta y al inicio', (tester) async {
    _usePhoneSurface(tester);
    await tester.pumpWidget(const UpaMatchApp());

    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.byType(CreateAccountScreen), findsOneWidget);
    expect(find.text('Cuéntanos sobre ti'), findsOneWidget);
    expect(find.text('Paso 2 de 5'), findsOneWidget);

    await tester.ensureVisible(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.byType(MainShell), findsOneWidget);
    expect(find.text('Max, 3'), findsOneWidget);
    expect(find.text('Nuevos cerca de ti'), findsOneWidget);
  });

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
}
