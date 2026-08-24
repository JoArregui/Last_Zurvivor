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

  /// Radio de visión del jugador.
  final double visionRadius = 150;

  /// Tamaño de cada celda del mapa.
  ///
  /// Cuanto menor sea el valor:
  /// - más suave será la forma de la zona descubierta
  /// - más celdas tendrá el mapa
  /// - mayor será el número de comprobaciones
  final double cellSize = 25;

  /// Distancia mínima que debe desplazarse el jugador
  /// antes de volver a calcular las zonas descubiertas.
  ///
  /// Esto evita hacer el cálculo en cada frame.
  final double discoveryUpdateDistance = 50;

  // ============================================================
  // MAPA
  // ============================================================

  late final int columns;
  late final int rows;

  late final List<bool> discovered;

  // ============================================================
  // POSICIÓN UTILIZADA EN EL ÚLTIMO CÁLCULO
  // ============================================================

  Vector2 _lastDiscoveryPosition = Vector2.zero();

  bool _initialized = false;

  // ============================================================
  // CACHÉ DE CELDAS NO DESCUBIERTAS
  // ============================================================

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

    // Guardamos la posición inicial del jugador.
    _lastDiscoveryPosition =
        player.position.clone();

    // Descubrimos inmediatamente la zona inicial.
    _discoverAroundPlayer();

    // Construimos la lista inicial de rectángulos.
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

    // ============================================================
    // COMPROBAR SI EL JUGADOR SE HA MOVIDO SUFICIENTEMENTE
    // ============================================================

    final distance =
        currentPosition.distanceTo(
      _lastDiscoveryPosition,
    );

    if (distance < discoveryUpdateDistance) {
      return;
    }

    // ============================================================
    // ACTUALIZAR DESCUBRIMIENTO
    // ============================================================

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
        // --------------------------------------------------------
        // FUERA DEL MAPA
        // --------------------------------------------------------

        if (x < 0 ||
            x >= columns ||
            y < 0 ||
            y >= rows) {
          continue;
        }

        final index = _index(x, y);

        // --------------------------------------------------------
        // SI YA ESTÁ DESCUBIERTA
        // --------------------------------------------------------

        if (discovered[index]) {
          continue;
        }

        // --------------------------------------------------------
        // CENTRO DE LA CELDA
        // --------------------------------------------------------

        final cellCenter = Vector2(
          x * cellSize + cellSize / 2,
          y * cellSize + cellSize / 2,
        );

        // --------------------------------------------------------
        // DISTANCIA AL JUGADOR
        // --------------------------------------------------------

        final distance =
            cellCenter.distanceTo(playerPosition);

        // --------------------------------------------------------
        // DESCUBRIR CELDA
        // --------------------------------------------------------

        if (distance <= visionRadius) {
          discovered[index] = true;
        }
      }
    }
  }

  // ============================================================
  // RECONSTRUIR RECTÁNGULOS DE NIEBLA
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
  // ÍNDICE DE CELDA
  // ============================================================

  int _index(int x, int y) {
    return y * columns + x;
  }

  // ============================================================
  // COMPROBAR SI UNA POSICIÓN ESTÁ DESCUBIERTA
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

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ============================================================
    // NIEBLA
    // ============================================================
    //
    // Solo dibujamos las zonas que todavía NO han sido
    // descubiertas.
    //
    // Las zonas descubiertas permanecen completamente visibles.
    //
    // Ya NO existe una segunda capa gris circular alrededor
    // del jugador.
    // ============================================================

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