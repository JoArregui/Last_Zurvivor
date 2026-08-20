import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'components/player/player.dart';
import 'components/world/game_world.dart';
import 'systems/enemy_spawner.dart';
import 'game_controller.dart';

class LastSurvivorGame extends FlameGame {
  LastSurvivorGame({
    required this.gameController,
  });

  final GameController gameController;

  late final GameWorld gameWorld;
  late final Player player;
  late final JoystickComponent joystick;
  late final EnemySpawner enemySpawner;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ============================================================
    // MUNDO (Fondo / Mapa)
    // ============================================================

    gameWorld = GameWorld();
    world.add(gameWorld);

    // ============================================================
    // JUGADOR
    // ============================================================

    player = Player(
      position: Vector2(
        1500,
        1500,
      ),
      gameController: gameController,
    );

    gameController.player = player;
    world.add(player);

    // ============================================================
    // CÁMARA
    // ============================================================

    camera.follow(player);

    // ============================================================
    // ENEMIGOS
    // ============================================================

    // Aquí está el cambio importante: pasamos "world" (el World de FlameGame)
    // para que los zombies nazcan como hermanos de Player y Projectile.
    enemySpawner = EnemySpawner(
      player: player,
      world: world, 
    );

    add(enemySpawner);

    // ============================================================
    // JOYSTICK
    // ============================================================

    joystick = JoystickComponent(
      knob: CircleComponent(
        radius: 20,
        paint: Paint()..color = Colors.white,
      ),
      background: CircleComponent(
        radius: 90,
        paint: Paint()..color = Colors.white.withOpacity(0.35),
      ),
      margin: const EdgeInsets.only(
        left: 40,
        bottom: 40,
      ),
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

    player.move(
      joystick.relativeDelta,
    );
  }

  void pauseGame() {
    pauseEngine();
  }

  void resumeGame() {
    resumeEngine();
  }
}