import 'package:flutter/widgets.dart';

import '../data/models/conversation.dart';
import '../data/models/profile.dart';
import '../features/auth/login_screen.dart';
import '../features/chats/chat_detail_screen.dart';
import '../features/onboarding/create_account_screen.dart';
import '../features/profile_detail/profile_detail_screen.dart';
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

  /// Recibe la [Conversation] como `arguments` de `pushNamed`.
  static const String chatDetail = '/chat';

  /// Recibe el [Profile] como `arguments`; devuelve una `SwipeDecision?`.
  static const String profileDetail = '/perfil-detalle';

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
        chatDetail: (context) => ChatDetailScreen(
              conversation:
                  ModalRoute.of(context)!.settings.arguments! as Conversation,
            ),
        profileDetail: (context) => ProfileDetailScreen(
              profile: ModalRoute.of(context)!.settings.arguments! as Profile,
            ),
      };
}
