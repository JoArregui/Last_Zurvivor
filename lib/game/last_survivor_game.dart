import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/player/player.dart';
import 'components/world/game_world.dart';
import 'components/world/fog_of_war.dart';
import 'systems/enemy_spawner.dart';
import 'game_controller.dart';

class LastSurvivorGame extends FlameGame {
  LastSurvivorGame({required this.gameController});

  final GameController gameController;

  late final GameWorld gameWorld;
  late final Player player;
  late final JoystickComponent joystick;
  late final EnemySpawner enemySpawner;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ============================================================
    // MUNDO
    // ============================================================

    gameWorld = GameWorld();

    world.add(gameWorld);

    // ============================================================
    // JUGADOR
    // ============================================================

    player = Player(
      position: Vector2(1500, 1500),
      gameController: gameController,
    );

    gameController.player = player;

    world.add(player);

    // ============================================================
    // NIEBLA DE GUERRA
    // ============================================================

    final fogOfWar = FogOfWar(player: player);

    world.add(fogOfWar);

    // ============================================================
    // CÁMARA
    // ============================================================

    camera.follow(player);

    // ============================================================
    // ENEMIGOS
    // ============================================================

    enemySpawner = EnemySpawner(player: player, world: world);

    add(enemySpawner);

    // ============================================================
    // JOYSTICK
    // ============================================================

    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.white),

      background: CircleComponent(
        radius: 50,
        paint: Paint()..color = Colors.white.withOpacity(0.30),
      ),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
      priority: 10,
    );

    camera.viewport.add(joystick);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ============================================================
    // MOVIMIENTO DEL JUGADOR
    // ============================================================

    player.move(joystick.relativeDelta);
  }

  void pauseGame() {
    pauseEngine();
  }

  void resumeGame() {
    resumeEngine();
  }
}
