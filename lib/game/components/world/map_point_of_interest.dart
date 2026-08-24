import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../systems/rewards/reward.dart';
import '../../systems/rewards/reward_type.dart';
import '../player/player.dart';

enum PointOfInterestType {
  house,
  warehouse,
  medical,
  chest,
}

class MapPointOfInterest extends PositionComponent {
  MapPointOfInterest({
    required Vector2 position,
    required this.type,
  }) : super(
          position: position,
          size: Vector2.all(70),
          anchor: Anchor.center,
          priority: 50,
        );

  final PointOfInterestType type;

  final Random _random = Random();

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  /// Distancia para descubrir/interactuar.
  final double interactionRadius = 110;

  bool discovered = false;
  bool used = false;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (used) return;

    final players = parent?.children.whereType<Player>();

    if (players == null || players.isEmpty) return;

    final player = players.first;

    final distance = position.distanceTo(player.position);

    if (distance <= interactionRadius) {
      _discover();
    }
  }

  // ============================================================
  // DESCUBRIR PUNTO
  // ============================================================

  void _discover() {
    if (discovered) return;

    discovered = true;

    debugPrint("PUNTO DESCUBIERTO: ${type.name}");

    _spawnReward();
  }

  // ============================================================
  // GENERAR RECOMPENSA
  // ============================================================

  void _spawnReward() {
    if (used) return;

    used = true;

    final rewardType = _chooseReward();

    // Pequeño desplazamiento para que aparezca al lado.
    final offset = Vector2(
      (_random.nextDouble() - 0.5) * 40,
      (_random.nextDouble() - 0.5) * 40,
    );

    parent?.add(
      Reward(
        position: position + offset,
        type: rewardType,
      ),
    );
  }

  // ============================================================
  // SELECCIONAR RECOMPENSA
  // ============================================================

  RewardType _chooseReward() {
    switch (type) {
      // ----------------------------------------------------------
      // CASA
      // ----------------------------------------------------------

      case PointOfInterestType.house:
        return _random.nextBool()
            ? RewardType.heal
            : RewardType.maxHealth;

      // ----------------------------------------------------------
      // HOSPITAL
      // ----------------------------------------------------------

      case PointOfInterestType.medical:
        return _random.nextInt(100) < 75
            ? RewardType.heal
            : RewardType.maxHealth;

      // ----------------------------------------------------------
      // ALMACÉN
      // ----------------------------------------------------------

      case PointOfInterestType.warehouse:
        switch (_random.nextInt(3)) {
          case 0:
            return RewardType.damage;
          case 1:
            return RewardType.attackSpeed;
          default:
            return RewardType.movementSpeed;
        }

      // ----------------------------------------------------------
      // COFRE
      // ----------------------------------------------------------

      case PointOfInterestType.chest:
        return RewardType.values[
            _random.nextInt(RewardType.values.length)];
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (type) {
      case PointOfInterestType.house:
        _renderHouse(canvas);
        break;

      case PointOfInterestType.warehouse:
        _renderWarehouse(canvas);
        break;

      case PointOfInterestType.medical:
        _renderMedical(canvas);
        break;

      case PointOfInterestType.chest:
        _renderChest(canvas);
        break;
    }

    // Halo amarillo cuando se descubre.
    if (discovered && !used) {
      _renderDiscoveryIndicator(canvas);
    }

    // Punto ya utilizado → se dibuja gris.
    if (used) {
      final paint = Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2 + 4,
        paint,
      );
    }
  }

  // ============================================================
  // HALO DE DESCUBRIMIENTO
  // ============================================================

  void _renderDiscoveryIndicator(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 + 5,
      paint,
    );
  }

  // ============================================================
  // CASA
  // ============================================================

  void _renderHouse(Canvas canvas) {
    final bodyPaint = Paint()
      ..color = used ? Colors.grey.shade700 : Colors.brown
      ..style = PaintingStyle.fill;

    final roofPaint = Paint()
      ..color = used ? Colors.grey.shade600 : Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(10, 25, 50, 35),
      bodyPaint,
    );

    final roof = Path()
      ..moveTo(5, 25)
      ..lineTo(35, 5)
      ..lineTo(65, 25)
      ..close();

    canvas.drawPath(roof, roofPaint);

    canvas.drawRect(
      const Rect.fromLTWH(28, 42, 14, 18),
      Paint()..color = Colors.black,
    );
  }

  // ============================================================
  // ALMACÉN
  // ============================================================

  void _renderWarehouse(Canvas canvas) {
    final bodyPaint = Paint()
      ..color =
          used ? Colors.grey.shade700 : Colors.blueGrey
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(
      const Rect.fromLTWH(5, 15, 60, 45),
      bodyPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(5, 15, 60, 45),
      borderPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(22, 32, 26, 28),
      Paint()..color = Colors.black,
    );
  }

  // ============================================================
  // HOSPITAL
  // ============================================================

  void _renderMedical(Canvas canvas) {
    final bodyPaint = Paint()
      ..color =
          used ? Colors.grey.shade300 : Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(5, 5, 60, 60),
      bodyPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(5, 5, 60, 60),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    final crossPaint = Paint()
      ..color =
          used ? Colors.grey : Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(28, 15, 14, 40),
      crossPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(15, 28, 40, 14),
      crossPaint,
    );
  }

  // ============================================================
  // COFRE
  // ============================================================

  void _renderChest(Canvas canvas) {
    final chestPaint = Paint()
      ..color =
          used ? Colors.grey.shade700 : Colors.amber
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(8, 20, 54, 35),
      chestPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(8, 20, 54, 35),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    canvas.drawCircle(
      const Offset(35, 38),
      5,
      Paint()..color = Colors.black,
    );
  }
}