import 'package:flutter/material.dart';

import '../../game/game_controller.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    super.key,
    required this.controller,
    required this.onRestart,
  });

  final GameController controller;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.80),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(30),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.red,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // ICONO
                // ==================================================

                const Icon(
                  Icons.dangerous,
                  color: Colors.red,
                  size: 80,
                ),

                const SizedBox(height: 20),

                // ==================================================
                // GAME OVER
                // ==================================================

                const Text(
                  'GAME OVER',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // NIVEL
                // ==================================================

                Text(
                  'Nivel alcanzado: ${controller.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // EXPERIENCIA
                // ==================================================

                Text(
                  'Experiencia: '
                  '${controller.hud.experience.toStringAsFixed(0)} / '
                  '${controller.hud.experienceToNextLevel.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // BOTÓN REINTENTAR
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: onRestart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'REINTENTAR',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}