import 'dart:math' as math;

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
  // ANIMACIÓN NORMAL
  // ============================================================

  double _animationTime = 0;

  /// Desplazamiento vertical máximo.
  final double floatAmplitude = 4;

  /// Velocidad de flotación/pulso.
  final double animationSpeed = 3;

  /// Escala mínima del pulso.
  final double pulseMin = 0.90;

  /// Escala máxima del pulso.
  final double pulseMax = 1.10;

  /// Desplazamiento visual vertical.
  double _visualFloatOffset = 0;

  // ============================================================
  // ANIMACIÓN DE RECOGIDA
  // ============================================================

  double _collectAnimationTime = 0;

  /// Duración total del efecto de recogida.
  final double collectAnimationDuration = 0.20;

  /// Escala máxima durante la recogida.
  final double collectMaxScale = 1.8;

  /// Radio máximo del destello.
  final double collectFlashRadius = 32;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    // ============================================================
    // ANIMACIÓN DE RECOGIDA
    // ============================================================

    if (_collected) {
      _collectAnimationTime += dt;

      if (_collectAnimationTime >= collectAnimationDuration) {
        removeFromParent();
      }

      return;
    }

    // ============================================================
    // COMPROBAR JUGADOR
    // ============================================================

    if (!player.isMounted) {
      return;
    }

    // ============================================================
    // ANIMACIÓN NORMAL
    // ============================================================

    _animationTime += dt * animationSpeed;

    _visualFloatOffset =
        math.sin(_animationTime) * floatAmplitude;

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

    // Aplicamos inmediatamente el efecto.
    _applyReward();

    // El componente NO se elimina inmediatamente.
    //
    // Se mantiene durante unos milisegundos para poder
    // reproducir la animación visual de recogida.
    _collectAnimationTime = 0;
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

    // ============================================================
    // ANIMACIÓN DE RECOGIDA
    // ============================================================

    if (_collected) {
      _renderCollectEffect(canvas);
      return;
    }

    // ============================================================
    // PULSO NORMAL
    // ============================================================

    final pulse =
        (math.sin(_animationTime) + 1) / 2;

    final scale =
        pulseMin +
        (pulseMax - pulseMin) * pulse;

    // ============================================================
    // CENTRO VISUAL
    // ============================================================

    final center = Offset(
      size.x / 2,
      size.y / 2 + _visualFloatOffset,
    );

    // ============================================================
    // HALO
    // ============================================================

    final haloPaint = Paint()
      ..color = _getColor().withOpacity(
        0.15 + pulse * 0.20,
      )
      ..style = PaintingStyle.fill;

    final haloRadius =
        (size.x / 2 + 6) * scale;

    canvas.drawCircle(
      center,
      haloRadius,
      haloPaint,
    );

    // ============================================================
    // CUERPO
    // ============================================================

    final rewardRadius =
        (size.x / 2) * scale;

    final paint = Paint()
      ..color = _getColor()
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      rewardRadius,
      paint,
    );

    // ============================================================
    // BORDE
    // ============================================================

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      center,
      rewardRadius - 1,
      borderPaint,
    );

    // ============================================================
    // SÍMBOLO
    // ============================================================

    _renderSymbol(
      canvas,
      center,
    );
  }

  // ============================================================
  // EFECTO DE RECOGIDA
  // ============================================================

  void _renderCollectEffect(Canvas canvas) {
    final progress =
        (_collectAnimationTime / collectAnimationDuration)
            .clamp(0.0, 1.0);

    // ============================================================
    // CURVA DE ANIMACIÓN
    // ============================================================

    final easedProgress =
        Curves.easeOut.transform(progress);

    // ============================================================
    // CENTRO
    // ============================================================

    final center = Offset(
      size.x / 2,
      size.y / 2,
    );

    // ============================================================
    // DESTELLO EXTERIOR
    // ============================================================

    final flashRadius =
        collectFlashRadius * easedProgress;

    final flashOpacity =
        (1.0 - easedProgress) * 0.75;

    final flashPaint = Paint()
      ..color = Colors.white.withOpacity(
        flashOpacity,
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      flashRadius,
      flashPaint,
    );

    // ============================================================
    // HALO DEL COLOR DEL REWARD
    // ============================================================

    final haloRadius =
        (size.x / 2 + 8) +
        (20 * easedProgress);

    final haloOpacity =
        (1.0 - easedProgress) * 0.6;

    final haloPaint = Paint()
      ..color = _getColor().withOpacity(
        haloOpacity,
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      haloRadius,
      haloPaint,
    );

    // ============================================================
    // REWARD QUE SE EXPANDE
    // ============================================================

    final rewardScale =
        1.0 +
        (collectMaxScale - 1.0) * easedProgress;

    final rewardRadius =
        (size.x / 2) * rewardScale;

    final rewardOpacity =
        1.0 - easedProgress;

    final rewardPaint = Paint()
      ..color = _getColor().withOpacity(
        rewardOpacity,
      )
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center,
      rewardRadius,
      rewardPaint,
    );

    // ============================================================
    // BORDE
    // ============================================================

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(
        rewardOpacity,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      center,
      rewardRadius - 1,
      borderPaint,
    );

    // ============================================================
    // SÍMBOLO
    // ============================================================

    if (rewardOpacity > 0.05) {
      _renderSymbol(
        canvas,
        center,
        opacity: rewardOpacity,
        scale: rewardScale,
      );
    }
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

  void _renderSymbol(
    Canvas canvas,
    Offset center, {
    double opacity = 1.0,
    double scale = 1.0,
  }) {
    final textRenderer = TextPaint(
      style: TextStyle(
        color: Colors.white.withOpacity(opacity),
        fontSize: 16 * scale,
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

    final textWidth = symbol == 'XP'
        ? 20 * scale
        : 16 * scale;

    final textHeight = 16 * scale;

    textRenderer.render(
      canvas,
      symbol,
      Vector2(
        center.dx - textWidth / 2,
        center.dy - textHeight / 2,
      ),
    );
  }
}