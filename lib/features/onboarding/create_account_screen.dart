import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/circle_icon_button.dart';
import '../../core/widgets/gradient_button.dart';
import '../../core/widgets/phone_chrome.dart';
import '../../core/widgets/pill_chip.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/profile.dart';
import '../../routes/app_routes.dart';

/// 02 · Crear cuenta (paso 2 de 5)
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  static const int step = 2;
  static const int totalSteps = 5;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _nameController = TextEditingController(text: 'Max');
  final _cityController = TextEditingController(text: 'Aguascalientes');

  ProfileKind _kind = ProfileKind.perro;
  String _age = '3 años';
  final Set<String> _lookingFor = {'Amistad', 'Paseos'};

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const MockStatusBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.pagePadding,
                6,
                AppTheme.pagePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.chevron_left_rounded,
                        size: 40,
                        iconSize: 24,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          'Paso ${CreateAccountScreen.step} de '
                          '${CreateAccountScreen.totalSteps}',
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _StepProgressBar(
                    step: CreateAccountScreen.step,
                    total: CreateAccountScreen.totalSteps,
                  ),
                  const SizedBox(height: 20),
                  const Text('Cuéntanos sobre ti', style: AppTextStyles.title),
                  const SizedBox(height: 6),
                  const Text(
                    'Tu perfil puede ser tuyo o de tu mascota',
                    style: AppTextStyles.bodyMuted,
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '¿De quién es este perfil?',
                    style: AppTextStyles.fieldLabel,
                  ),
                  const SizedBox(height: 10),
                  _KindGrid(
                    selected: _kind,
                    onChanged: (kind) => setState(() => _kind = kind),
                  ),
                  const SizedBox(height: 20),
                  LabeledField(
                    label: '¿Cómo se llama?',
                    child: AppTextField(controller: _nameController),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: LabeledField(
                          label: 'Edad',
                          child: AppDropdownBox(
                            value: _age,
                            onTap: _pickAge,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LabeledField(
                          label: 'Ciudad',
                          child: AppTextField(controller: _cityController),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('¿Qué buscas?', style: AppTextStyles.fieldLabel),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final option in MockData.lookingForOptions)
                          PillChip.choice(
                            label: option,
                            selected: _lookingFor.contains(option),
                            onTap: () => setState(() {
                              if (!_lookingFor.remove(option)) {
                                _lookingFor.add(option);
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  GradientButton(
                    label: 'Continuar',
                    // TODO(backend): guardar el paso y avanzar al paso 3.
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.home),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
          const HomeIndicator(),
        ],
      ),
    );
  }

  Future<void> _pickAge() async {
    final options = <String>[
      for (var i = 1; i <= 15; i++) '$i ${i == 1 ? 'año' : 'años'}',
    ];

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusSheet),
        ),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            for (final option in options)
              ListTile(
                title: Text(option, style: AppTextStyles.body),
                trailing: option == _age
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary, size: 20)
                    : null,
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );

    if (picked != null && mounted) setState(() => _age = picked);
  }
}

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            const ColoredBox(
              color: AppColors.surfaceMuted,
              child: SizedBox(width: double.infinity, height: 6),
            ),
            FractionallySizedBox(
              widthFactor: step / total,
              child: const DecoratedBox(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                child: SizedBox(height: 6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KindGrid extends StatelessWidget {
  const _KindGrid({required this.selected, required this.onChanged});

  final ProfileKind selected;
  final ValueChanged<ProfileKind> onChanged;

  static const Map<ProfileKind, Color> _avatarColors = {
    ProfileKind.persona: AppColors.avatarBlue,
    ProfileKind.perro: AppColors.avatarTan,
    ProfileKind.gato: AppColors.avatarPeach,
    ProfileKind.otro: AppColors.avatarMint,
  };

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 165 / 76,
      children: [
        for (final kind in ProfileKind.values)
          _KindCard(
            kind: kind,
            avatarColor: _avatarColors[kind]!,
            selected: kind == selected,
            onTap: () => onChanged(kind),
          ),
      ],
    );
  }
}

class _KindCard extends StatelessWidget {
  const _KindCard({
    required this.kind,
    required this.avatarColor,
    required this.selected,
    required this.onTap,
  });

  final ProfileKind kind;
  final Color avatarColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(
                  color: selected ? AppColors.primaryLight : AppColors.border,
                  width: selected ? 1.8 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: avatarColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      kind.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      kind.label,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (selected)
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 14,
                color: AppColors.textOnDark,
              ),
            ),
          ),
      ],
    );
  }
}
