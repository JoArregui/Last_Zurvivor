import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';

class GameWorld extends RectangleComponent {
  GameWorld()
      : super(
          position: Vector2.zero(),
          size: Vector2(
            GameConstants.worldWidth,
            GameConstants.worldHeight,
          ),
          paint: Paint()..color = const Color(0xFF4A6741),
        );

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // --------------------------------------------------
    // BORDE DEL MAPA
    // --------------------------------------------------

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        size.x,
        size.y,
      ),
      borderPaint,
    );

    // --------------------------------------------------
    // CRUZ DEL CENTRO DEL MAPA
    // --------------------------------------------------

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