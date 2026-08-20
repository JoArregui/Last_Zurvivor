import 'package:flutter/material.dart';

import '../../game/game_controller.dart';

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
  });

  final String icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: onTap,
        child: Text(
          '$icon  $title',
          style: const TextStyle(
            fontSize: 18,
          ),
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