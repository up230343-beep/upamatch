import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/phone_chrome.dart';
<<<<<<< HEAD
=======
import '../../data/mis_solicitudes.dart';
import '../../routes/app_routes.dart';
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
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

<<<<<<< HEAD
  /// 0 Buscar match · 1 Solicitudes · 2 Mi perfil
=======
  /// 0 Explorar · 1 Likes · 2 Perfil
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
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
<<<<<<< HEAD
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
=======
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
>>>>>>> 5b6cbb61c6471783f4a83832a2eacacd038eb8c6
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
