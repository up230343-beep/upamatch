import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'data/api/cuentas_service.dart';
import 'data/session/sesion.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  // Si ya había iniciado sesión, entra directo. Solo se olvida la sesión si la
  // API dice que ya no sirve; sin conexión se entra igual.
  await SesionActual.cargar();
  if (SesionActual.valor != null && !await CuentasService.sesionSigueValida()) {
    await SesionActual.cerrar();
  }

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
      initialRoute: AppRoutes.initial,
      onGenerateInitialRoutes: AppRoutes.initialRoutes,
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
