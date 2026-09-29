import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/phone_chrome.dart';
import '../explore/explore_screen.dart';
import '../profile/profile_screen.dart';
import '../solicitudes/solicitudes_screen.dart';
import 'widgets/main_bottom_nav.dart';

/// Contenedor de las tres pestañas.
///
/// La barra de estado, la barra inferior y el home indicator viven aquí, así
/// que cada pantalla solo se ocupa de su contenido.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  /// 0 Buscar match · 1 Solicitudes · 2 Mi perfil
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MockStatusBar(),
          Expanded(
            // Cada pestana se arma al entrar, asi siempre trae datos frescos
            // (por ejemplo, un match nuevo aparece sin tener que refrescar).
            child: switch (_index) {
              0 => const ExploreScreen(),
              1 => const SolicitudesScreen(),
              _ => const ProfileScreen(),
            },
          ),
          MainBottomNav(
            currentIndex: _index,
            onTap: (index) => setState(() => _index = index),
          ),
          const ColoredBox(
            color: AppColors.surface,
            child: SizedBox(
              width: double.infinity,
              child: HomeIndicator(),
            ),
          ),
        ],
      ),
    );
  }
}
