import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../components/player/player.dart';
import 'reward_type.dart';

class Reward extends PositionComponent {
  Reward({
    required Vector2 position,
    required this.type,
    required this.player,
  }) : super(
          position: position,
          size: Vector2.all(35),
          anchor: Anchor.center,
          priority: 60,
        );

  final RewardType type;

  final Player player;

  bool _collected = false;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (_collected) {
      return;
    }

    if (!player.isMounted) {
      return;
    }

    // ============================================================
    // POSICIONES ABSOLUTAS
    // ============================================================

    final rewardPosition = absolutePosition;
    final playerPosition = player.absolutePosition;

    // ============================================================
    // TAMAÑOS
    // ============================================================

    final rewardHalfWidth = size.x / 2;
    final rewardHalfHeight = size.y / 2;

    final playerHalfWidth = player.size.x / 2;
    final playerHalfHeight = player.size.y / 2;

    // ============================================================
    // LÍMITES DE LA RECOMPENSA
    // ============================================================

    final rewardLeft =
        rewardPosition.x - rewardHalfWidth;

    final rewardRight =
        rewardPosition.x + rewardHalfWidth;

    final rewardTop =
        rewardPosition.y - rewardHalfHeight;

    final rewardBottom =
        rewardPosition.y + rewardHalfHeight;

    // ============================================================
    // LÍMITES DEL JUGADOR
    // ============================================================

    final playerLeft =
        playerPosition.x - playerHalfWidth;

    final playerRight =
        playerPosition.x + playerHalfWidth;

    final playerTop =
        playerPosition.y - playerHalfHeight;

    final playerBottom =
        playerPosition.y + playerHalfHeight;

    // ============================================================
    // COMPROBAR SOLAPAMIENTO
    // ============================================================

    final overlaps =
        playerRight >= rewardLeft &&
        playerLeft <= rewardRight &&
        playerBottom >= rewardTop &&
        playerTop <= rewardBottom;

    // ============================================================
    // RECOGER
    // ============================================================

    if (overlaps) {
      _collect();
    }
  }

  // ============================================================
  // RECOGER RECOMPENSA
  // ============================================================

  void _collect() {
    if (_collected) {
      return;
    }

    _collected = true;

    debugPrint(
      'RECOMPENSA RECOGIDA: ${type.name}',
    );

    _applyReward();

    removeFromParent();
  }

  // ============================================================
  // APLICAR RECOMPENSA
  // ============================================================

  void _applyReward() {
    switch (type) {
      case RewardType.heal:
        player.stats.heal(30);
        break;

      case RewardType.maxHealth:
        player.stats.increaseMaxHealth(25);
        break;

      case RewardType.damage:
        player.stats.increaseDamage(0.20);
        break;

      case RewardType.attackSpeed:
        player.stats.increaseAttackSpeed(0.20);
        break;

      case RewardType.movementSpeed:
        player.stats.increaseMovementSpeed(0.15);
        break;

      case RewardType.experience:
        player.gainExperience(50);
        break;
    }

    player.refreshHud();
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 - 1,
      borderPaint,
    );

    _renderSymbol(canvas);
  }

  // ============================================================
  // COLOR
  // ============================================================

  Color _getColor() {
    switch (type) {
      case RewardType.heal:
        return Colors.red;

      case RewardType.maxHealth:
        return Colors.pink;

      case RewardType.damage:
        return Colors.orange;

      case RewardType.attackSpeed:
        return Colors.yellow;

      case RewardType.movementSpeed:
        return Colors.blue;

      case RewardType.experience:
        return Colors.purple;
    }
  }

  // ============================================================
  // SÍMBOLO
  // ============================================================

  void _renderSymbol(Canvas canvas) {
    final textRenderer = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    String symbol;

    switch (type) {
      case RewardType.heal:
        symbol = '+';
        break;

      case RewardType.maxHealth:
        symbol = '♥';
        break;

      case RewardType.damage:
        symbol = '⚔';
        break;

      case RewardType.attackSpeed:
        symbol = '⚡';
        break;

      case RewardType.movementSpeed:
        symbol = '»';
        break;

      case RewardType.experience:
        symbol = 'XP';
        break;
    }

    textRenderer.render(
      canvas,
      symbol,
      Vector2(
        size.x / 2 - 10,
        size.y / 2 - 10,
      ),
    );
  }
}