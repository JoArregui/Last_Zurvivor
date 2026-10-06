import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../enemies/zombie.dart';
import '../../../core/theme/game_theme.dart';
import '../planes/plane_sprites.dart';

class Projectile extends PositionComponent {
  Projectile({
    required Vector2 position,
    required Vector2 direction,
    required this.damage,
    required this.speed,
  }) : super(
          position: position,
          size: Vector2.all(10),
          anchor: Anchor.center,
        ) {
    _direction = direction.normalized();
  }

  // ============================================================
  // DAÑO
  // ============================================================

  final double damage;

  // ============================================================
  // VELOCIDAD
  // ============================================================

  final double speed;

  late final Vector2 _direction;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    // ------------------------------------------------------------
    // MOVIMIENTO
    // ------------------------------------------------------------

    position += _direction * speed * dt;

    // ------------------------------------------------------------
    // BUSCAR ZOMBIS
    // ------------------------------------------------------------

    final zombies =
        parent?.children.whereType<Zombie>();

    if (zombies == null) {
      return;
    }

    // ------------------------------------------------------------
    // COLISIÓN
    // ------------------------------------------------------------

    for (final zombie in zombies) {
      if (zombie.state == ZombieState.dead) {
        continue;
      }

      if (position.distanceTo(zombie.position) < 25) {
        zombie.takeDamage(damage);

        removeFromParent();

        break;
      }
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Rafaga trazadora (Desktop/Aviones bullet.png, vertical).
    final tracer = PlaneSprites.useSprites
        ? PlaneSprites.bullet
        : null;

    if (tracer != null) {
      final angle = math.atan2(_direction.y, _direction.x) +
          math.pi / 2;

      // Proporcion original 35x151.
      final drawH = size.x * 3.2;
      final drawW = drawH * (35 / 151);

      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(angle);
      tracer.render(
        canvas,
        position: Vector2(-drawW / 2, -drawH / 2),
        size: Vector2(drawW, drawH),
      );
      canvas.restore();
      return;
    }

    final paint = Paint()
      ..color = GameThemes.current.projectileColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        size.x / 2,
        size.y / 2,
      ),
      5,
      paint,
    );
  }
}