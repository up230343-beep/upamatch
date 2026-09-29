import 'package:flutter/material.dart';

import '../data/models/mascota.dart';
import '../data/models/profile.dart';
import '../data/models/solicitud.dart';
import '../data/session/sesion.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/onboarding/create_account_screen.dart';
import '../features/profile_detail/profile_detail_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/solicitudes/solicitud_detalle_screen.dart';

/// Rutas con nombre de la app.
///
/// Explorar, Likes y Perfil son pestañas de [MainShell]: se entra por
/// [home] y se cambia con la barra inferior.
///
/// Todo lo que no sea login o registro pide sesión: si no la hay (por ejemplo,
/// al recargar la página en `/#/inicio` después de cerrar sesión) se muestra el
/// login.
abstract final class AppRoutes {
  static const String login = '/';

  /// Paso 1 del registro: correo y contraseña.
  static const String register = '/registro';

  /// Paso 2 del registro: datos de la mascota.
  static const String createAccount = '/crear-cuenta';
  static const String home = '/inicio';

  /// Recibe la [Mascota] actual como `arguments`; devuelve la guardada.
  static const String editProfile = '/editar-perfil';

  /// Recibe el [Profile] como `arguments`; devuelve una `SwipeDecision?`.
  static const String profileDetail = '/perfil-detalle';

  /// Perfil completo de una solicitud. Recibe la `Solicitud` como `arguments`;
  /// si es pendiente devuelve una `SwipeDecision?` ("sí" o "no").
  static const String solicitudDetalle = '/solicitud';

  /// Adónde entra la app al abrirse según la sesión guardada.
  static String get initial {
    final sesion = SesionActual.valor;
    if (sesion == null) return login;
    return sesion.tienePerfil ? home : createAccount;
  }

  /// Índices de las pestañas de [MainShell].
  static const int tabExplore = 0;
  static const int tabLikes = 1;
  static const int tabProfile = 2;

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        register: (_) => const RegisterScreen(),
        createAccount: _conSesion((_) => const CreateAccountScreen()),
        home: _conPerfil((_) => const MainShell()),
        editProfile: _conPerfil(
          (context) => CreateAccountScreen(
            inicial: ModalRoute.of(context)!.settings.arguments! as Mascota,
          ),
        ),
        profileDetail: _conPerfil(
          (context) => ProfileDetailScreen(
            profile: ModalRoute.of(context)!.settings.arguments! as Profile,
          ),
        ),
        solicitudDetalle: _conPerfil(
          (context) => SolicitudDetalleScreen(
            solicitud:
                ModalRoute.of(context)!.settings.arguments! as Solicitud,
          ),
        ),
      };

  /// Solo la primera pantalla, sin apilar el login debajo (así "atrás" no
  /// regresa al login cuando ya hay sesión).
  static List<Route<dynamic>> initialRoutes(String name) {
    final builder = routes[name] ?? routes[login]!;
    return [
      MaterialPageRoute<dynamic>(
        settings: RouteSettings(name: name),
        builder: builder,
      ),
    ];
  }

  static WidgetBuilder _conSesion(WidgetBuilder builder) => (context) =>
      SesionActual.valor == null ? const LoginScreen() : builder(context);

  static WidgetBuilder _conPerfil(WidgetBuilder builder) => (context) {
        final sesion = SesionActual.valor;
        if (sesion == null) return const LoginScreen();
        if (!sesion.tienePerfil) return const CreateAccountScreen();
        return builder(context);
      };
}
