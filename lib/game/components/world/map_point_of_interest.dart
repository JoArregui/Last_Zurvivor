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
    required this.player, 
  }) : super(
          position: position,
          size: Vector2.all(70),
          anchor: Anchor.center,
          priority: 50,
        );

  final PointOfInterestType type;
  final Player player; 

  final Random _random = Random();

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  /// Distancia a la que el jugador descubre el punto de interés.
  final double interactionRadius = 110;

  /// Indica si el punto ya ha sido descubierto.
  bool discovered = false;

  /// Indica si el punto ya ha sido utilizado.
  ///
  /// Una vez utilizado no volverá a generar recompensas.
  bool used = false;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    // Si ya se ha utilizado, no hacemos nada.
    if (used) {
      return;
    }

    // Distancia entre el jugador y el punto de interés.
    final distance = position.distanceTo(player.position);

    // Si el jugador está suficientemente cerca,
    // descubrimos el punto.
    if (distance <= interactionRadius) {
      _discover(player);
    }
  }

  // ============================================================
  // DESCUBRIR PUNTO
  // ============================================================

  void _discover(Player player) {
    // Evitamos descubrirlo varias veces.
    if (discovered) {
      return;
    }

    discovered = true;

    debugPrint(
      'PUNTO DESCUBIERTO: ${type.name}',
    );

    // Generamos la recompensa.
    //
    // IMPORTANTE:
    // Pasamos el player como parámetro porque Reward necesita
    // conocer al jugador para comprobar la distancia y aplicar
    // la recompensa.
    _spawnReward(player);
  }

  // ============================================================
  // GENERAR RECOMPENSA
  // ============================================================

  void _spawnReward(Player player) {
    // Si ya fue utilizado, no generamos otra recompensa.
    if (used) {
      return;
    }

    used = true;

    // Elegimos aleatoriamente qué recompensa generar.
    final rewardType = _chooseReward();

    // Pequeño desplazamiento aleatorio.
    //
    // Esto evita que la recompensa aparezca exactamente
    // en el centro del punto de interés.
    final offset = Vector2(
      (_random.nextDouble() - 0.5) * 40,
      (_random.nextDouble() - 0.5) * 40,
    );

    // Añadimos la recompensa al mismo padre que contiene
    // el punto de interés.
    //
    // De esta forma Reward y MapPointOfInterest están en
    // las mismas coordenadas del mundo.
    parent?.add(
      Reward(
        position: position + offset,
        type: rewardType,
        player: player,
      ),
    );

    debugPrint(
      'RECOMPENSA GENERADA: ${rewardType.name}',
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
            _random.nextInt(
              RewardType.values.length,
            )
        ];
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

    // ============================================================
    // INDICADOR DE DESCUBRIMIENTO
    // ============================================================

    if (discovered && !used) {
      _renderDiscoveryIndicator(canvas);
    }

    // ============================================================
    // PUNTO UTILIZADO
    // ============================================================

    if (used) {
      final paint = Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
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

    // Cuerpo de la casa.
    canvas.drawRect(
      const Rect.fromLTWH(
        10,
        25,
        50,
        35,
      ),
      bodyPaint,
    );

    // Tejado.
    final roof = Path()
      ..moveTo(5, 25)
      ..lineTo(35, 5)
      ..lineTo(65, 25)
      ..close();

    canvas.drawPath(
      roof,
      roofPaint,
    );

    // Puerta.
    canvas.drawRect(
      const Rect.fromLTWH(
        28,
        42,
        14,
        18,
      ),
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

    // Cuerpo.
    canvas.drawRect(
      const Rect.fromLTWH(
        5,
        15,
        60,
        45,
      ),
      bodyPaint,
    );

    // Borde.
    canvas.drawRect(
      const Rect.fromLTWH(
        5,
        15,
        60,
        45,
      ),
      borderPaint,
    );

    // Puerta grande.
    canvas.drawRect(
      const Rect.fromLTWH(
        22,
        32,
        26,
        28,
      ),
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

    // Edificio.
    canvas.drawRect(
      const Rect.fromLTWH(
        5,
        5,
        60,
        60,
      ),
      bodyPaint,
    );

    // Borde.
    canvas.drawRect(
      const Rect.fromLTWH(
        5,
        5,
        60,
        60,
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Cruz.
    final crossPaint = Paint()
      ..color =
          used ? Colors.grey : Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      const Rect.fromLTWH(
        28,
        15,
        14,
        40,
      ),
      crossPaint,
    );

    canvas.drawRect(
      const Rect.fromLTWH(
        15,
        28,
        40,
        14,
      ),
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

    // Cofre.
    canvas.drawRect(
      const Rect.fromLTWH(
        8,
        20,
        54,
        35,
      ),
      chestPaint,
    );

    // Borde.
    canvas.drawRect(
      const Rect.fromLTWH(
        8,
        20,
        54,
        35,
      ),
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Cerradura.
    canvas.drawCircle(
      const Offset(35, 38),
      5,
      Paint()..color = Colors.black,
    );
  }
}