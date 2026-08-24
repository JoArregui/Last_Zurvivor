import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../player/player.dart';
import 'map_point_of_interest.dart';

class GameWorld extends RectangleComponent {
  GameWorld({required this.player})
    : super(
        position: Vector2.zero(),
        size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
        paint: Paint()..color = const Color(0xFF4A6741),
        priority: 0,
      );

  final Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // ============================================================
    // PUNTOS DE INTERÉS
    // ============================================================

    add(
      MapPointOfInterest(
        position: Vector2(900, 900),
        type: PointOfInterestType.house,
        player: player,
      ),
    );

    add(
      MapPointOfInterest(
        position: Vector2(2100, 900),
        type: PointOfInterestType.warehouse,
        player: player,
      ),
    );

    add(
      MapPointOfInterest(
        position: Vector2(900, 2100),
        type: PointOfInterestType.medical,
        player: player,
      ),
    );

    add(
      MapPointOfInterest(
        position: Vector2(2100, 2100),
        type: PointOfInterestType.chest,
        player: player,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ============================================================
    // BORDE DEL MAPA
    // ============================================================

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), borderPaint);

    // ============================================================
    // CRUZ DEL CENTRO DEL MAPA
    // ============================================================

    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 4;

    final centerX = size.x / 2;
    final centerY = size.y / 2;

    canvas.drawLine(
      Offset(centerX - 100, centerY),
      Offset(centerX + 100, centerY),
      centerPaint,
    );

    canvas.drawLine(
      Offset(centerX, centerY - 100),
      Offset(centerX, centerY + 100),
      centerPaint,
    );
  }
}
