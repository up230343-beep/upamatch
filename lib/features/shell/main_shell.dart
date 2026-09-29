import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../data/mis_solicitudes.dart';
import '../../routes/app_routes.dart';
import '../explore/explore_screen.dart';
import '../likes/likes_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/main_bottom_nav.dart';

/// Contenedor de las tres pestañas.
///
/// La barra de estado, la barra inferior y el home indicator viven aquí, así
/// que cada pantalla solo se ocupa de su contenido.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialIndex = 0});

  /// 0 Explorar · 1 Likes · 2 Perfil
  final int initialIndex;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _index = widget.initialIndex;

  @override
  void initState() {
    super.initState();
    // Las solicitudes se piden al entrar: las usan la pestaña y el globito.
    // Después del primer cuadro, para no avisar a nadie a media construcción.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => MisSolicitudes.instancia.cargar(),
    );
  }

  void _cambiarPestana(int index) {
    // Al abrir solicitudes se actualizan, por si llegó alguna nueva.
    if (index == AppRoutes.tabLikes && index != _index) {
      MisSolicitudes.instancia.cargar();
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MockStatusBar(),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: const [
                ExploreScreen(),
                LikesScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          ListenableBuilder(
            listenable: MisSolicitudes.instancia,
            builder: (context, _) => MainBottomNav(
              currentIndex: _index,
              likesBadge: MisSolicitudes.instancia.pendientes.length,
              onTap: _cambiarPestana,
            ),
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
