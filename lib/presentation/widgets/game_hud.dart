import 'package:flutter/material.dart';

import '../../game/models/hud_data.dart';

class GameHud extends StatelessWidget {
  const GameHud({
    super.key,
    required this.hud,
  });

  final HudData hud;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LV ${hud.level}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 4,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            _ExperienceBar(hud: hud),

            const SizedBox(height: 12),

            _HealthBar(hud: hud),
          ],
        ),
      ),
    );
  }
}

class _ExperienceBar extends StatelessWidget {
  const _ExperienceBar({
    required this.hud,
  });

  final HudData hud;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'XP',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 4),

        SizedBox(
          width: 220,
          height: 12,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hud.experienceProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.black54,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Colors.amber,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HealthBar extends StatelessWidget {
  const _HealthBar({
    required this.hud,
  });

  final HudData hud;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '❤️ ${hud.health.toInt()} / ${hud.maxHealth.toInt()}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                blurRadius: 4,
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        SizedBox(
          width: 220,
          height: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: hud.healthProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.black54,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(
                Colors.red,
              ),
            ),
          ),
        ),
      ],
    );
  }
}