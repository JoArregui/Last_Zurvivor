import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game/game_controller.dart';
import 'game/last_survivor_game.dart';
import 'presentation/widgets/game_hud.dart';
import 'presentation/widgets/level_up_overlay.dart';
import 'presentation/widgets/game_over_overlay.dart';
import 'game/systems/progression/upgrade.dart';
import 'game/systems/progression/upgrade_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => GameController(),
      child: const LastSurvivorApp(),
    ),
  );
}

class LastSurvivorApp extends StatelessWidget {
  const LastSurvivorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late LastSurvivorGame game;

  @override
  void initState() {
    super.initState();

    final controller = context.read<GameController>();

    game = LastSurvivorGame(
      gameController: controller,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<GameController>();

    return Scaffold(
      body: Stack(
        children: [
          // ======================================================
          // FLAME GAME
          // ======================================================

          GameWidget(
            key: ValueKey(game),
            game: game,
          ),

          // ======================================================
          // HUD
          // ======================================================

          if (!controller.isGameOver)
            GameHud(
              hud: controller.hud,
            ),

          // ======================================================
          // LEVEL UP
          // ======================================================

          if (controller.isLevelUp)
            LevelUpOverlay(
              controller: controller,
              onUpgradeSelected: (option) {
                _selectUpgrade(
                  context,
                  option,
                );
              },
            ),

          // ======================================================
          // GAME OVER
          // ======================================================

          if (controller.isGameOver)
            GameOverOverlay(
              controller: controller,
              onRestart: _restartGame,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // LEVEL UP
  // ============================================================

  void _selectUpgrade(
    BuildContext context,
    UpgradeOption option,
  ) {
    final controller = context.read<GameController>();

    final player = controller.player;

    if (player == null) {
      return;
    }

    switch (option) {
      case UpgradeOption.damage:
        UpgradeService.applyUpgrade(
          player,
          UpgradeType.damage,
        );
        break;

      case UpgradeOption.speed:
        UpgradeService.applyUpgrade(
          player,
          UpgradeType.movementSpeed,
        );
        break;

      case UpgradeOption.health:
        UpgradeService.applyUpgrade(
          player,
          UpgradeType.maxHealth,
        );
        break;
    }

    controller.hideLevelUpScreen();

    player.refreshHud();
  }

  // ============================================================
  // REINICIAR PARTIDA
  // ============================================================

  void _restartGame() {
    final controller = context.read<GameController>();

    // Reiniciamos el estado del controlador.
    controller.restartGame();

    // Creamos una nueva partida Flame.
    setState(() {
      game = LastSurvivorGame(
        gameController: controller,
      );
    });
  }
}