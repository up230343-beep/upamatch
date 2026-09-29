import 'package:flutter/widgets.dart';

import '../features/auth/login_screen.dart';
import '../features/onboarding/create_account_screen.dart';
import '../features/shell/main_shell.dart';

/// Rutas con nombre de la app.
///
/// Buscar match, Solicitudes y Mi perfil son pestanas de [MainShell]: se entra
/// por [home] y se cambia con la barra de abajo.
abstract final class AppRoutes {
  static const String login = '/';
  static const String createAccount = '/crear-cuenta';
  static const String home = '/inicio';

  static const String initial = login;

  /// Indices de las pestanas de [MainShell].
  static const int tabBuscar = 0;
  static const int tabSolicitudes = 1;
  static const int tabPerfil = 2;

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        createAccount: (_) => const CreateAccountScreen(),
        home: (_) => const MainShell(),
      };
}
