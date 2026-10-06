import 'package:flutter/material.dart';

import '../../core/theme/game_theme.dart';
import '../../game/game_controller.dart';

/// Iconos de la variante zombie: bala y corazon de Desktop/Zombies
/// en vez de emojis. Sin asset para velocidad (emoji clasico).
String? _zombieIconAsset(UpgradeOption option) {
  if (GameThemes.current.id != GameVariantId.zombies) {
    return null;
  }
  switch (option) {
    case UpgradeOption.damage:
      return 'assets/images/zombies/bullet.png';
    case UpgradeOption.speed:
      return null;
    case UpgradeOption.health:
      return 'assets/images/zombies/heart.png';
  }
}

class LevelUpOverlay extends StatelessWidget {
  const LevelUpOverlay({
    super.key,
    required this.controller,
    required this.onUpgradeSelected,
  });

  final GameController controller;

  final void Function(UpgradeOption option)
      onUpgradeSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'LEVEL UP!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Nivel ${controller.level}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 24),

              _UpgradeButton(
                icon: '🔫',
                title: '+20% DAÑO',
                iconAsset:
                    _zombieIconAsset(UpgradeOption.damage),
                onTap: () {
                  onUpgradeSelected(
                    UpgradeOption.damage,
                  );
                },
              ),

              const SizedBox(height: 12),

              _UpgradeButton(
                icon: '🏃',
                title: '+15% VELOCIDAD',
                iconAsset:
                    _zombieIconAsset(UpgradeOption.speed),
                onTap: () {
                  onUpgradeSelected(
                    UpgradeOption.speed,
                  );
                },
              ),

              const SizedBox(height: 12),

              _UpgradeButton(
                icon: '❤️',
                title: '+30 VIDA',
                iconAsset:
                    _zombieIconAsset(UpgradeOption.health),
                onTap: () {
                  onUpgradeSelected(
                    UpgradeOption.health,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UpgradeButton extends StatelessWidget {
  const _UpgradeButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconAsset,
  });

  final String icon;
  final String title;
  final VoidCallback onTap;

  /// Sprite de Desktop/Zombies (rama zombies). Si null, emoji clásico.
  final String? iconAsset;

  @override
  Widget build(BuildContext context) {
    final leading = iconAsset != null
        ? Image.asset(
            iconAsset!,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(
              icon,
              style: const TextStyle(fontSize: 20),
            ),
          )
        : Text(
            icon,
            style: const TextStyle(fontSize: 20),
          );

    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum UpgradeOption {
  damage,
  speed,
  health,
}