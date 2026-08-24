import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../components/player/player.dart';
import '../../components/world/fog_of_war.dart';
import '../../components/world/map_point_of_interest.dart';
import '../../systems/rewards/reward.dart';
import '../../systems/rewards/reward_type.dart';

class MiniMap extends StatelessWidget {
  const MiniMap({
    super.key,
    required this.player,
    required this.fogOfWar,
    required this.mapPoints,
    required this.rewards,
  });

  final Player player;
  final FogOfWar fogOfWar;

  final List<MapPointOfInterest> mapPoints;
  final List<Reward> rewards;

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  static const double mapSize = 150;

  static const double borderWidth = 3;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        width: mapSize,
        height: mapSize,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.75),
          border: Border.all(
            color: Colors.white,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.hardEdge,
        child: CustomPaint(
          painter: _MiniMapPainter(
            player: player,
            fogOfWar: fogOfWar,
            mapPoints: mapPoints,
            rewards: rewards,
          ),
        ),
      ),
    );
  }
}

// ================================================================
// PAINTER
// ================================================================

class _MiniMapPainter extends CustomPainter {
  _MiniMapPainter({
    required this.player,
    required this.fogOfWar,
    required this.mapPoints,
    required this.rewards,
  });

  final Player player;
  final FogOfWar fogOfWar;

  final List<MapPointOfInterest> mapPoints;
  final List<Reward> rewards;

  // ============================================================
  // TAMAÑO DEL MAPA DEL JUEGO
  // ============================================================

  static const double worldSize = 3000.0;

  // ============================================================
  // PAINT
  // ============================================================

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / worldSize;
    final scaleY = size.height / worldSize;

    // ============================================================
    // FONDO
    // ============================================================

    final backgroundPaint = Paint()
      ..color = const Color(0xFF263326)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.width,
        size.height,
      ),
      backgroundPaint,
    );

    // ============================================================
    // CUADRÍCULA
    // ============================================================

    _drawGrid(
      canvas,
      size,
      scaleX,
      scaleY,
    );

    // ============================================================
    // PUNTOS DE INTERÉS
    // ============================================================

    for (final point in mapPoints) {
      if (!_isDiscovered(point.position)) {
        continue;
      }

      _drawPointOfInterest(
        canvas,
        point,
        scaleX,
        scaleY,
      );
    }

    // ============================================================
    // RECOMPENSAS
    // ============================================================

    for (final reward in rewards) {
      if (!_isDiscovered(reward.position)) {
        continue;
      }

      _drawReward(
        canvas,
        reward,
        scaleX,
        scaleY,
      );
    }

    // ============================================================
    // JUGADOR
    // ============================================================

    _drawPlayer(
      canvas,
      scaleX,
      scaleY,
    );
  }

  // ============================================================
  // COMPROBAR DESCUBRIMIENTO
  // ============================================================

  bool _isDiscovered(Vector2 position) {
    return fogOfWar.isDiscovered(position);
  }

  // ============================================================
  // CONVERTIR POSICIÓN DEL MUNDO AL MINIMAPA
  // ============================================================

  Offset _worldToMiniMap(
    double x,
    double y,
    double scaleX,
    double scaleY,
  ) {
    return Offset(
      x * scaleX,
      y * scaleY,
    );
  }

  // ============================================================
  // CUADRÍCULA
  // ============================================================

  void _drawGrid(
    Canvas canvas,
    Size size,
    double scaleX,
    double scaleY,
  ) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    const gridSize = 500.0;

    for (double x = 0; x <= worldSize; x += gridSize) {
      final screenX = x * scaleX;

      canvas.drawLine(
        Offset(screenX, 0),
        Offset(screenX, size.height),
        gridPaint,
      );
    }

    for (double y = 0; y <= worldSize; y += gridSize) {
      final screenY = y * scaleY;

      canvas.drawLine(
        Offset(0, screenY),
        Offset(size.width, screenY),
        gridPaint,
      );
    }
  }

  // ============================================================
  // JUGADOR
  // ============================================================

  void _drawPlayer(
    Canvas canvas,
    double scaleX,
    double scaleY,
  ) {
    final position = _worldToMiniMap(
      player.position.x,
      player.position.y,
      scaleX,
      scaleY,
    );

    // Punto azul
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      position,
      5,
      paint,
    );

    // Borde blanco
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      position,
      5,
      borderPaint,
    );
  }

  // ============================================================
  // PUNTO DE INTERÉS
  // ============================================================

  void _drawPointOfInterest(
    Canvas canvas,
    MapPointOfInterest point,
    double scaleX,
    double scaleY,
  ) {
    final position = _worldToMiniMap(
      point.position.x,
      point.position.y,
      scaleX,
      scaleY,
    );

    Color color;

    switch (point.type) {
      case PointOfInterestType.house:
        color = Colors.brown;
        break;

      case PointOfInterestType.warehouse:
        color = Colors.blueGrey;
        break;

      case PointOfInterestType.medical:
        color = Colors.red;
        break;

      case PointOfInterestType.chest:
        color = Colors.amber;
        break;
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      position,
      4,
      paint,
    );
  }

  // ============================================================
  // RECOMPENSA
  // ============================================================

  void _drawReward(
    Canvas canvas,
    Reward reward,
    double scaleX,
    double scaleY,
  ) {
    final position = _worldToMiniMap(
      reward.position.x,
      reward.position.y,
      scaleX,
      scaleY,
    );

    final paint = Paint()
      ..color = _rewardColor(reward)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      position,
      3,
      paint,
    );
  }

  // ============================================================
  // COLOR DE RECOMPENSA
  // ============================================================

  Color _rewardColor(Reward reward) {
    switch (reward.type) {
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
  // SHOULD REPAINT
  // ============================================================

  @override
  bool shouldRepaint(
    covariant _MiniMapPainter oldDelegate,
  ) {
    return true;
  }
}