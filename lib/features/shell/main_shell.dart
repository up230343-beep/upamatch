import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../data/mock/mock_data.dart';
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
          MainBottomNav(
            currentIndex: _index,
            likesBadge: MockData.likesReceived.length,
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
