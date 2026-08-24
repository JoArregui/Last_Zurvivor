import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../components/player/player.dart';
import '../../systems/rewards/reward_type.dart';


class Reward extends PositionComponent {
  Reward({required Vector2 position, required this.type})
    : super(
        position: position,
        size: Vector2.all(35),
        anchor: Anchor.center,
        priority: 60,
      );

  final RewardType type;

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

    final players = parent?.children.whereType<Player>();

    if (players == null || players.isEmpty) {
      return;
    }

    final player = players.first;

    final distance = position.distanceTo(player.position);

    // Distancia necesaria para recoger la recompensa.
    const pickupDistance = 45.0;

    if (distance <= pickupDistance) {
      _collect(player);
    }
  }

  // ============================================================
  // RECOGER RECOMPENSA
  // ============================================================

  void _collect(Player player) {
    if (_collected) {
      return;
    }

    _collected = true;

    // Aplicamos el efecto.
    _applyReward(player);

    // Desaparece del mapa.
    removeFromParent();
  }

  // ============================================================
  // APLICAR RECOMPENSA
  // ============================================================

  void _applyReward(Player player) {
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

    // Actualizamos el HUD después de aplicar la recompensa.
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

    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, paint);

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

      case RewardType.maxHealth:
        symbol = '♥';

      case RewardType.damage:
        symbol = '⚔';

      case RewardType.attackSpeed:
        symbol = '⚡';

      case RewardType.movementSpeed:
        symbol = '»';

      case RewardType.experience:
        symbol = 'XP';
    }

    textRenderer.render(
      canvas,
      symbol,
      Vector2(size.x / 2 - 10, size.y / 2 - 10),
    );
  }
}
