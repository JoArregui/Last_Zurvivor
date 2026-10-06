import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../enemies/zombie.dart';
import '../../../core/theme/game_theme.dart';

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