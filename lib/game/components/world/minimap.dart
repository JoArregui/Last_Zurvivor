import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../player/player.dart';
import 'fog_of_war.dart';
import 'map_point_of_interest.dart';

class Minimap extends PositionComponent {
  Minimap({
    required this.player,
    required this.fogOfWar,
    required this.gameWorld,
  }) : super(
          size: Vector2.all(180),
          priority: 1000,
        );

  final Player player;

  final FogOfWar fogOfWar;

  final PositionComponent gameWorld;

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  static const double minimapSize = 180;

  static const double padding = 8;

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    size = Vector2.all(minimapSize);

    position = Vector2(
      15,
      15,
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================


  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ============================================================
    // FONDO
    // ============================================================

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.75)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          0,
          0,
          minimapSize,
          minimapSize,
        ),
        const Radius.circular(12),
      ),
      backgroundPaint,
    );

    // ============================================================
    // ÁREA DEL MAPA
    // ============================================================

    final mapRect = Rect.fromLTWH(
      padding,
      padding,
      minimapSize - padding * 2,
      minimapSize - padding * 2,
    );

    final mapPaint = Paint()
      ..color = const Color(0xFF4A6741)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      mapRect,
      mapPaint,
    );

    // ============================================================
    // NIEBLA
    // ============================================================

    _renderFog(
      canvas,
      mapRect,
    );

    // ============================================================
    // PUNTOS DE INTERÉS
    // ============================================================

    _renderPointsOfInterest(
      canvas,
      mapRect,
    );

    // ============================================================
    // JUGADOR
    // ============================================================

    _renderPlayer(
      canvas,
      mapRect,
    );

    // ============================================================
    // BORDE
    // ============================================================

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        mapRect,
        const Radius.circular(6),
      ),
      borderPaint,
    );
  }

  // ============================================================
  // NIEBLA DEL MINIMAPA
  // ============================================================

  void _renderFog(
    Canvas canvas,
    Rect mapRect,
  ) {
    final columns = fogOfWar.mapColumns;
    final rows = fogOfWar.mapRows;

    final cellWidth =
        mapRect.width / columns;

    final cellHeight =
        mapRect.height / rows;

    final fogPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.92)
      ..style = PaintingStyle.fill;

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        if (fogOfWar.isCellDiscovered(x, y)) {
          continue;
        }

        canvas.drawRect(
          Rect.fromLTWH(
            mapRect.left + x * cellWidth,
            mapRect.top + y * cellHeight,
            cellWidth + 0.5,
            cellHeight + 0.5,
          ),
          fogPaint,
        );
      }
    }
  }

  // ============================================================
  // JUGADOR
  // ============================================================

  void _renderPlayer(
    Canvas canvas,
    Rect mapRect,
  ) {
    final playerPosition = _worldToMinimap(
      player.position,
      mapRect,
    );

    final playerPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      playerPosition,
      4,
      playerPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(
      playerPosition,
      5,
      borderPaint,
    );
  }

  // ============================================================
  // PUNTOS DE INTERÉS
  // ============================================================

  void _renderPointsOfInterest(
    Canvas canvas,
    Rect mapRect,
  ) {
    final points =
        gameWorld.children.whereType<MapPointOfInterest>();

    for (final point in points) {
      // Los puntos no descubiertos permanecen ocultos.
      if (!fogOfWar.isDiscovered(point.position)) {
        continue;
      }

      final position = _worldToMinimap(
        point.position,
        mapRect,
      );

      final paint = Paint()
        ..color = _getPointColor(point.type)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        position,
        3,
        paint,
      );
    }
  }

  // ============================================================
  // COLOR DE LOS PUNTOS
  // ============================================================

  Color _getPointColor(
    PointOfInterestType type,
  ) {
    switch (type) {
      case PointOfInterestType.house:
        return Colors.red;

      case PointOfInterestType.warehouse:
        return Colors.blueGrey;

      case PointOfInterestType.medical:
        return Colors.white;

      case PointOfInterestType.chest:
        return Colors.amber;
    }
  }

  // ============================================================
  // CONVERSIÓN MAPA → MINIMAPA
  // ============================================================

  Offset _worldToMinimap(
    Vector2 worldPosition,
    Rect mapRect,
  ) {
    final normalizedX =
        worldPosition.x /
        GameConstants.worldWidth;

    final normalizedY =
        worldPosition.y /
        GameConstants.worldHeight;

    return Offset(
      mapRect.left +
          normalizedX * mapRect.width,
      mapRect.top +
          normalizedY * mapRect.height,
    );
  }
}