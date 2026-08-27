import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../game_controller.dart';
import '../../systems/progression/player_progression.dart';
import '../weapons/weapon.dart';
import 'player_stats.dart';

class Player extends PositionComponent {
  Player({
    required Vector2 position,
    required this.gameController,
  }) : super(
          position: position,
          size: Vector2.all(40),
          anchor: Anchor.center,
          priority: 200,
        );

  final PlayerStats stats = PlayerStats();

  final PlayerProgression progression = PlayerProgression();

  final GameController gameController;

  Vector2 velocity = Vector2.zero();

  late final Weapon weapon;

  // ============================================================
  // INFORMACIÓN DE LA OLEADA
  // ============================================================

  /// Número de oleada actual.
  ///
  /// Se actualiza desde LastSurvivorGame.
  int currentWave = 1;

  /// Número de zombis que quedan para completar la oleada.
  int zombiesRemaining = 0;

  // ============================================================
  // ACTUALIZAR HUD
  // ============================================================

  void _updateHud() {
    gameController.updateHud(
      level: progression.level,
      experience: progression.experience,
      experienceToNextLevel: progression.experienceToNextLevel,
      health: stats.health,
      maxHealth: stats.maxHealth,

      // Información de la oleada.
      wave: currentWave,
      zombiesRemaining: zombiesRemaining,
    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    weapon = Weapon(player: this);

    progression.onLevelUp = _onLevelUp;

    add(weapon);

    _updateHud();
  }

  // ============================================================
  // SUBIR DE NIVEL
  // ============================================================

  void _onLevelUp() {
    stop();

    _updateHud();

    gameController.showLevelUpScreen(
      progression.level,
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (velocity.length2 > 0) {
      position += velocity * dt;
    }

    _limitPosition();
  }

  // ============================================================
  // MOVIMIENTO
  // ============================================================

  void move(Vector2 direction) {
    if (direction.length2 == 0) {
      velocity = Vector2.zero();
      return;
    }

    velocity =
        direction.normalized() *
        stats.movementSpeed;
  }

  void stop() {
    velocity = Vector2.zero();
  }

  // ============================================================
  // LIMITAR POSICIÓN AL MAPA
  // ============================================================

  void _limitPosition() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    position.x = position.x.clamp(
      halfWidth,
      GameConstants.worldWidth - halfWidth,
    );

    position.y = position.y.clamp(
      halfHeight,
      GameConstants.worldHeight - halfHeight,
    );
  }

  // ============================================================
  // EXPERIENCIA
  // ============================================================

  void gainExperience(double amount) {
    progression.addExperience(amount);

    _updateHud();
  }

  // ============================================================
  // ACTUALIZAR HUD
  // ============================================================

  void refreshHud() {
    _updateHud();
  }

  // ============================================================
  // ACTUALIZAR INFORMACIÓN DE LA OLEADA
  // ============================================================

  void updateWaveInfo({
    required int wave,
    required int zombies,
  }) {
    currentWave = wave;
    zombiesRemaining = zombies;

    _updateHud();
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ============================================================
    // CUERPO DEL JUGADOR
    // ============================================================

    final playerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      size.x / 2,
      playerPaint,
    );

    // ============================================================
    // BORDE
    // ============================================================

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      size.x / 2 - 2,
      borderPaint,
    );

    // ============================================================
    // NIVEL
    // ============================================================

    final textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );

    textRenderer.render(
      canvas,
      'LV ${progression.level}',
      Vector2(-5, 45),
    );
  }
}