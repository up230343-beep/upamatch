import 'package:flutter/widgets.dart';

import '../features/auth/login_screen.dart';
import '../features/onboarding/create_account_screen.dart';
import '../features/shell/main_shell.dart';

/// Rutas con nombre de la app.
///
/// Explorar, Likes, Chats y Perfil son pestañas de [MainShell]: se entra por
/// [home] y se cambia con la barra inferior.
///
/// TODO(backend): la ruta inicial debería depender de si hay sesión guardada.
abstract final class AppRoutes {
  static const String login = '/';
  static const String createAccount = '/crear-cuenta';
  static const String home = '/inicio';

  static const String initial = login;

  /// Índices de las pestañas de [MainShell].
  static const int tabExplore = 0;
  static const int tabLikes = 1;
  static const int tabChats = 2;
  static const int tabProfile = 3;

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        createAccount: (_) => const CreateAccountScreen(),
        home: (_) => const MainShell(),
      };
}
