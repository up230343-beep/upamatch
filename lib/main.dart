import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'data/api/sesion.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  // Si la persona ya habia iniciado sesion, se entra directo a la app.
  await Sesion.cargar();

  runApp(const UpaMatchApp());
}

class UpaMatchApp extends StatelessWidget {
  const UpaMatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UpaMatch',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Sesion.hayCuenta ? AppRoutes.home : AppRoutes.login,
      routes: AppRoutes.routes,
      builder: (context, child) {
        // El diseño está pensado a 390 px de ancho (iPhone 14). En pantallas
        // anchas (web / tablet) centramos el contenido en ese ancho para que
        // se vea igual que en Figma.
        return ColoredBox(
          color: const Color(0xFFE9E4F4),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
