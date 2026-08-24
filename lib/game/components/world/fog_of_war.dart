import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/game_constants.dart';
import '../player/player.dart';

class FogOfWar extends Component {
  FogOfWar({
    required this.player,
  }) : super(priority: 100);

  final Player player;

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  final double visionRadius = 150;

  final double cellSize = 25;

  final double discoveryUpdateDistance = 50;

  // ============================================================
  // MAPA
  // ============================================================

  late final int columns;
  late final int rows;

  late final List<bool> discovered;

  Vector2 _lastDiscoveryPosition = Vector2.zero();

  bool _initialized = false;

  final List<Rect> _undiscoveredRects = [];

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    columns =
        (GameConstants.worldWidth / cellSize).ceil();

    rows =
        (GameConstants.worldHeight / cellSize).ceil();

    discovered = List<bool>.filled(
      columns * rows,
      false,
    );

    _lastDiscoveryPosition =
        player.position.clone();

    _discoverAroundPlayer();

    _rebuildUndiscoveredRects();

    _initialized = true;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    if (!_initialized) {
      return;
    }

    final currentPosition = player.position;

    final distance =
        currentPosition.distanceTo(
      _lastDiscoveryPosition,
    );

    if (distance < discoveryUpdateDistance) {
      return;
    }

    _lastDiscoveryPosition =
        currentPosition.clone();

    _discoverAroundPlayer();

    _rebuildUndiscoveredRects();
  }

  // ============================================================
  // DESCUBRIR TERRENO
  // ============================================================

  void _discoverAroundPlayer() {
    final playerPosition = player.position;

    final centerX =
        (playerPosition.x / cellSize).floor();

    final centerY =
        (playerPosition.y / cellSize).floor();

    final cellRadius =
        (visionRadius / cellSize).ceil();

    for (
      var y = centerY - cellRadius;
      y <= centerY + cellRadius;
      y++
    ) {
      for (
        var x = centerX - cellRadius;
        x <= centerX + cellRadius;
        x++
      ) {
        if (x < 0 ||
            x >= columns ||
            y < 0 ||
            y >= rows) {
          continue;
        }

        final index = _index(x, y);

        if (discovered[index]) {
          continue;
        }

        final cellCenter = Vector2(
          x * cellSize + cellSize / 2,
          y * cellSize + cellSize / 2,
        );

        final distance =
            cellCenter.distanceTo(playerPosition);

        if (distance <= visionRadius) {
          discovered[index] = true;
        }
      }
    }
  }

  // ============================================================
  // RECONSTRUIR NIEBLA
  // ============================================================

  void _rebuildUndiscoveredRects() {
    _undiscoveredRects.clear();

    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < columns; x++) {
        final index = _index(x, y);

        if (discovered[index]) {
          continue;
        }

        _undiscoveredRects.add(
          Rect.fromLTWH(
            x * cellSize,
            y * cellSize,
            cellSize,
            cellSize,
          ),
        );
      }
    }
  }

  // ============================================================
  // ÍNDICE
  // ============================================================

  int _index(int x, int y) {
    return y * columns + x;
  }

  // ============================================================
  // API PARA EL MINIMAPA
  // ============================================================

  bool isDiscovered(Vector2 position) {
    final x =
        (position.x / cellSize).floor();

    final y =
        (position.y / cellSize).floor();

    if (x < 0 ||
        x >= columns ||
        y < 0 ||
        y >= rows) {
      return false;
    }

    return discovered[_index(x, y)];
  }

  /// Permite al minimapa comprobar una celda concreta.
  bool isCellDiscovered(int x, int y) {
    if (x < 0 ||
        x >= columns ||
        y < 0 ||
        y >= rows) {
      return false;
    }

    return discovered[_index(x, y)];
  }

  int get mapColumns => columns;

  int get mapRows => rows;

  double get mapCellSize => cellSize;

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final fogPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;

    for (final rect in _undiscoveredRects) {
      canvas.drawRect(
        rect,
        fogPaint,
      );
    }
  }
}