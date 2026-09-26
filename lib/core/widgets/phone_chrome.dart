import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Barra de estado "9:41" del mockup.
///
/// En un dispositivo real el sistema operativo ya la dibuja, así que aquí solo
/// reservamos el alto seguro. En web (y escritorio) no existe esa barra, por lo
/// que la pintamos para que la vista previa sea idéntica a Figma.
class MockStatusBar extends StatelessWidget {
  const MockStatusBar({super.key, this.foreground = AppColors.textPrimary});

  final Color foreground;

  static bool get isSimulated => kIsWeb;

  @override
  Widget build(BuildContext context) {
    if (!isSimulated) {
      return SizedBox(height: MediaQuery.paddingOf(context).top);
    }

    return SizedBox(
      height: 44,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 24, 0),
        child: Row(
          children: [
            Text(
              '9:41',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
            const Spacer(),
            _SignalBars(color: foreground),
            const SizedBox(width: 6),
            _Battery(color: foreground),
          ],
        ),
      ),
    );
  }
}

class _SignalBars extends StatelessWidget {
  const _SignalBars({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        return Container(
          width: 3,
          height: 4.0 + i * 2.5,
          margin: const EdgeInsets.only(left: 1.5),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }
}

class _Battery extends StatelessWidget {
  const _Battery({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 11.5,
          padding: const EdgeInsets.all(1.5),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
            borderRadius: BorderRadius.circular(3.5),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.85,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 1.5),
        Container(
          width: 1.5,
          height: 4,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ],
    );
  }
}

/// Barra inferior tipo "home indicator" de iOS.
class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    if (!MockStatusBar.isSimulated) {
      return SizedBox(height: MediaQuery.paddingOf(context).bottom);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 9),
      child: Center(
        child: Container(
          width: 134,
          height: 5,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
