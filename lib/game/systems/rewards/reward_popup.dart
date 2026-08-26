import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class RewardPopup extends PositionComponent {
  RewardPopup({
    required Vector2 position,
    required this.text,
    required this.color,
  }) : super(
          position: position,
          size: Vector2(180, 50),
          anchor: Anchor.center,
          priority: 100,
        );

  final String text;
  final Color color;

  // ============================================================
  // CONFIGURACIÓN
  // ============================================================

  /// Duración total del texto.
  static const double duration = 0.80;

  /// Cuánto sube el texto.
  static const double riseDistance = 45;

  /// Tamaño inicial del texto.
  static const double fontSize = 20;

  // ============================================================
  // ESTADO
  // ============================================================

  double _elapsed = 0;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    _elapsed += dt;

    // ------------------------------------------------------------
    // DESAPARECER AL TERMINAR
    // ------------------------------------------------------------

    if (_elapsed >= duration) {
      removeFromParent();
      return;
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ============================================================
    // PROGRESO
    // ============================================================

    final progress =
        (_elapsed / duration).clamp(0.0, 1.0);

    // ============================================================
    // MOVIMIENTO VERTICAL
    // ============================================================

    final easedProgress =
        Curves.easeOut.transform(progress);

    final offsetY =
        -riseDistance * easedProgress;

    // ============================================================
    // OPACIDAD
    // ============================================================

    final opacity =
        (1.0 - progress).clamp(0.0, 1.0);

    // ============================================================
    // TEXTO
    // ============================================================

    final textRenderer = TextPaint(
      style: TextStyle(
        color: color.withOpacity(opacity),
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(
              opacity * 0.9,
            ),
            offset: const Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
    );

    // ============================================================
    // POSICIÓN
    // ============================================================

    final textPosition = Vector2(
      size.x / 2 - _calculateTextOffset(),
      size.y / 2 + offsetY,
    );

    textRenderer.render(
      canvas,
      text,
      textPosition,
    );
  }

  // ============================================================
  // AJUSTE HORIZONTAL
  // ============================================================

  double _calculateTextOffset() {
    // Aproximación suficiente para centrar los textos habituales.
    return text.length * 5.5;
  }
}