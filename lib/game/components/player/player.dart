import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/constants/game_constants.dart';
import '../../../core/theme/game_theme.dart';
import '../../game_controller.dart';
import '../../systems/progression/player_progression.dart';
import '../weapons/weapon.dart';
import '../space/space_sprites.dart';
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
  // ACTUALIZAR HUD
  // ============================================================

  void _updateHud() {
    gameController.updateHud(
      level: progression.level,
      experience: progression.experience,
      experienceToNextLevel: progression.experienceToNextLevel,
      health: stats.health,
      maxHealth: stats.maxHealth,

    );
  }

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Velocidad base segun variante (aviones / zombies / naves).
    stats.movementSpeed = GameThemes.current.playerSpeed;

    // Variante espacial: precarga sprites (player/naves, fondo).
    await SpaceSprites.ensureLoaded();

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
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ============================================================
    // NAVE ESPACIAL (variante naves, Desktop/Espacio)
    // ============================================================

    final ship = SpaceSprites.useSprites
        ? SpaceSprites.player
        : null;

    if (ship != null) {
      // La imagen mira a la derecha (+X): rotamos hacia la velocidad.
      final hasDirection = velocity.length2 > 0.01;
      final angle = hasDirection
          ? math.atan2(velocity.y, velocity.x)
          : 0.0;

      // Proporcion original 429x261.
      final drawW = size.x * 2.4;
      final drawH = drawW * (261 / 429);
      final cx = size.x / 2;
      final cy = size.y / 2;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      ship.render(
        canvas,
        position: Vector2(-drawW / 2, -drawH / 2),
        size: Vector2(drawW, drawH),
      );
      canvas.restore();
    } else {
      // Fallback resto de variantes: circulo por tema.
      final playerPaint = Paint()
        ..color = GameThemes.current.playerColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          size.x / 2,
          size.y / 2,
        ),
        size.x / 2,
        playerPaint,
      );

      final borderPaint = Paint()
        ..color = GameThemes.current.playerBorderColor
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
    }

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