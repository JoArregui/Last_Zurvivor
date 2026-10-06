import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../../../core/theme/game_theme.dart';
import '../player/player.dart';
import '../planes/plane_sprites.dart';
import 'map_point_of_interest.dart';

class GameWorld extends RectangleComponent {
  GameWorld({required this.player})
    : super(
        position: Vector2.zero(),
        size: Vector2(GameConstants.worldWidth, GameConstants.worldHeight),
        paint: Paint()..color = GameThemes.current.worldBackground,
        priority: 0,
      );

  final Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Variante aviones: oceano en mosaico.
    await PlaneSprites.ensureLoaded();

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

    // Mosaico de oceano (Desktop/Aviones background_tile.jpg).
    final tile = PlaneSprites.useSprites
        ? PlaneSprites.backgroundTile
        : null;

    if (tile != null) {
      final tw = tile.width.toDouble();
      final th = tile.height.toDouble();
      final src =
          Rect.fromLTWH(0, 0, tw, th);
      final paint = Paint()..filterQuality = FilterQuality.none;
      for (double y = 0; y < size.y; y += th) {
        for (double x = 0; x < size.x; x += tw) {
          canvas.drawImageRect(
            tile,
            src,
            Rect.fromLTWH(x, y, tw, th),
            paint,
          );
        }
      }
    }

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
