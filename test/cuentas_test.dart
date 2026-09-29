import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upamatch/features/auth/login_screen.dart';
import 'package:upamatch/features/auth/register_screen.dart';
import 'package:upamatch/features/onboarding/create_account_screen.dart';
import 'package:upamatch/features/shell/main_shell.dart';
import 'package:upamatch/features/shell/widgets/main_bottom_nav.dart';
import 'package:upamatch/data/session/sesion.dart';
import 'package:upamatch/main.dart';

import 'helpers/api_falsa.dart';

Future<void> _escribirCredenciales(
  WidgetTester tester,
  String correo,
  String contrasena,
) async {
  final campos = find.byType(TextField);
  await tester.enterText(campos.at(0), correo);
  await tester.enterText(campos.at(1), contrasena);
}

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _irAPerfil(WidgetTester tester) async {
  await tester.tap(find.descendant(
    of: find.byType(MainBottomNav),
    matching: find.text('Perfil'),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('inicio de sesión', () {
    setUp(() => prepararApiFalsa(conSesion: false));

    testWidgets('el login se dibuja con sus textos principales',
        (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());

      expect(find.text('UpaMatch'), findsOneWidget);
      expect(find.text('Iniciar sesión'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('¿Olvidaste tu contraseña?'), findsOneWidget);
      expect(find.text('¿No tienes cuenta? Regístrate'), findsOneWidget);
      // Sin login con redes sociales.
      expect(find.text('Google'), findsNothing);
      expect(find.text('o continúa con'), findsNothing);
    });

    testWidgets('sin datos no deja pasar', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());

      await _tocar(tester, find.text('Iniciar sesión'));

      expect(find.text('Escribe tu correo.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('revisa el formato del correo y que haya contraseña',
        (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());

      await _escribirCredenciales(tester, 'max@upamatch', contrasenaValida);
      await _tocar(tester, find.text('Iniciar sesión'));
      expect(find.text('Escribe un correo válido.'), findsOneWidget);

      await _escribirCredenciales(tester, correoValido, '');
      await _tocar(tester, find.text('Iniciar sesión'));
      expect(find.text('Escribe tu contraseña.'), findsOneWidget);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('datos incorrectos: mismo mensaje y no entra', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());

      await _escribirCredenciales(tester, correoValido, 'otra-contrasena');
      await _tocar(tester, find.text('Iniciar sesión'));
      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);

      await _escribirCredenciales(tester, 'nadie@upamatch.mx', contrasenaValida);
      await _tocar(tester, find.text('Iniciar sesión'));
      expect(find.text('Correo o contraseña incorrectos.'), findsOneWidget);

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(SesionActual.valor, isNull);
    });

    testWidgets('datos correctos: entra y recuerda la sesión', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());

      await _escribirCredenciales(tester, correoValido, contrasenaValida);
      await _tocar(tester, find.text('Iniciar sesión'));

      expect(find.byType(MainShell), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('sesion.token'), 'token-de-prueba');
    });
  });

  group('registro en 2 pasos', () {
    setUp(() => prepararApiFalsa(conSesion: false));

    Future<void> abrirRegistro(WidgetTester tester) async {
      await tester.pumpWidget(const UpaMatchApp());
      await _tocar(tester, find.text('¿No tienes cuenta? Regístrate'));
      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Paso 1 de 2'), findsOneWidget);
    }

    Future<void> llenarPaso1(
      WidgetTester tester, {
      required String correo,
      String contrasena = contrasenaValida,
      String? confirmar,
    }) async {
      final campos = find.byType(TextField);
      await tester.enterText(campos.at(0), correo);
      await tester.enterText(campos.at(1), contrasena);
      await tester.enterText(campos.at(2), confirmar ?? contrasena);
      await _tocar(tester, find.text('Crear cuenta'));
    }

    testWidgets('las contraseñas deben coincidir', (tester) async {
      usarPantallaDeTelefono(tester);
      await abrirRegistro(tester);

      await llenarPaso1(tester, correo: 'nuevo@upamatch.mx', confirmar: 'x');
      expect(find.text('Las contraseñas no coinciden.'), findsOneWidget);
    });

    testWidgets('avisa si el correo ya está registrado', (tester) async {
      usarPantallaDeTelefono(tester);
      await abrirRegistro(tester);

      await llenarPaso1(tester, correo: correoRegistrado);
      expect(
        find.text('Ese correo ya está registrado. Inicia sesión.'),
        findsOneWidget,
      );
      expect(find.byType(RegisterScreen), findsOneWidget);
    });

    testWidgets('paso 1 → paso 2 → inicio', (tester) async {
      usarPantallaDeTelefono(tester);
      await abrirRegistro(tester);

      await llenarPaso1(tester, correo: 'nuevo@upamatch.mx');
      expect(find.byType(CreateAccountScreen), findsOneWidget);
      expect(find.text('Paso 2 de 2'), findsOneWidget);

      // Sin nombre no avanza.
      await _tocar(tester, find.text('Continuar'));
      expect(find.text('Escribe el nombre.'), findsOneWidget);

      final campos = find.byType(TextField);
      await tester.enterText(campos.at(0), 'Luna');
      await _tocar(tester, find.text('Elige'));
      await _tocar(tester, find.text('2 años'));
      await tester.enterText(campos.at(1), 'León');
      await _tocar(tester, find.text('Paseos'));

      // Sin Instagram no avanza: es el único contacto después del match.
      await _tocar(tester, find.text('Continuar'));
      expect(find.text('Escribe tu Instagram.'), findsOneWidget);

      await tester.enterText(campos.at(4), 'no válido!');
      await _tocar(tester, find.text('Continuar'));
      expect(find.textContaining('El Instagram no es válido'), findsOneWidget);

      await tester.enterText(campos.at(4), '@luna.husky');
      await _tocar(tester, find.text('Continuar'));

      expect(find.byType(MainShell), findsOneWidget);
      expect(perfilMax['nombre'], 'Luna');
      expect(perfilMax['edad'], 2);
      expect(perfilMax['intereses'], ['Paseos']);
      expect(perfilMax['instagram'], 'https://www.instagram.com/luna.husky');
      expect(SesionActual.valor!.tienePerfil, isTrue);
    });
  });

  group('sesión guardada y mi perfil', () {
    setUp(() => prepararApiFalsa());

    testWidgets('con sesión guardada entra directo', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsNothing);
      expect(find.byType(MainShell), findsOneWidget);
    });

    testWidgets('mi perfil muestra los datos de la API', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());
      await tester.pumpAndSettle();
      await _irAPerfil(tester);

      expect(find.text('Max, 3'), findsOneWidget);
      expect(find.text('Golden Retriever · Aguascalientes'), findsOneWidget);
      expect(find.text('Amo correr en la playa.'), findsOneWidget);
      expect(find.text('@max.golden'), findsOneWidget);
    });

    testWidgets('editar perfil guarda y se ve el cambio', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());
      await tester.pumpAndSettle();
      await _irAPerfil(tester);

      await _tocar(tester, find.text('Editar perfil'));
      expect(find.text('Guardar cambios'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Maximiliano');
      await _tocar(tester, find.text('Guardar cambios'));

      expect(perfilMax['nombre'], 'Maximiliano');
      expect(find.text('Maximiliano, 3'), findsOneWidget);
    });

    testWidgets('cerrar sesión la olvida y regresa al login', (tester) async {
      usarPantallaDeTelefono(tester);
      await tester.pumpWidget(const UpaMatchApp());
      await tester.pumpAndSettle();
      await _irAPerfil(tester);

      await _tocar(tester, find.text('Cerrar sesión'));

      expect(find.byType(LoginScreen), findsOneWidget);
      expect(SesionActual.valor, isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('sesion.token'), isNull);
    });
  });
}
