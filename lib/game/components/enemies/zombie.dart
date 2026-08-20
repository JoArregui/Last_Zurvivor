import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../player/player.dart';

enum ZombieState {
  idle,
  chasing,
  attacking,
  dead,
}

enum ZombieType {
  normal(
    health: 100,
    speed: 70,
    size: 36,
    color: Colors.red,
    xpReward: 25,
  ),
  fast(
    health: 50,
    speed: 120,
    size: 28,
    color: Colors.orange,
    xpReward: 20,
  ),
  tank(
    health: 300,
    speed: 40,
    size: 50,
    color: Colors.purple,
    xpReward: 60,
  );

  const ZombieType({
    required this.health,
    required this.speed,
    required this.size,
    required this.color,
    required this.xpReward,
  });

  final double health;
  final double speed;
  final double size;
  final Color color;
  final double xpReward;
}

class Zombie extends PositionComponent {
  Zombie({
    required Vector2 position,
    required this.player,
    this.type = ZombieType.normal,
  }) : super(
          position: position,
          size: Vector2.all(type.size),
          anchor: Anchor.center,
        ) {
    maxHealth = type.health;
    health = type.health;
    speed = type.speed;
    xpReward = type.xpReward;
    color = type.color;
  }

  final Player player;
  final ZombieType type;

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  late double health;
  late double maxHealth;
  late double speed;
  late double xpReward;
  late Color color;

  // ============================================================
  // ATAQUE
  // ============================================================

  /// Daño que hace este zombi al jugador.
  double attackDamage = 10;

  /// Tiempo mínimo entre ataques.
  double attackCooldown = 0.8;

  /// Distancia a la que el zombi deja de perseguir y empieza a atacar.
  double attackRange = 40;

  /// Temporizador interno del ataque.
  double _attackTimer = 0;

  // ============================================================
  // ESTADO
  // ============================================================

  ZombieState state = ZombieState.idle;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    // Si está muerto, no hacemos absolutamente nada.
    if (state == ZombieState.dead) {
      return;
    }

    // Si el jugador ya está muerto, dejamos de atacar.
    if (player.stats.health <= 0) {
      state = ZombieState.idle;
      return;
    }

    final distance = position.distanceTo(player.position);

    // ============================================================
    // ATAQUE
    // ============================================================

    if (distance <= attackRange) {
      state = ZombieState.attacking;

      _attackTimer -= dt;

      if (_attackTimer <= 0) {
        _attackPlayer();

        _attackTimer = attackCooldown;
      }

      return;
    }

    // ============================================================
    // PERSECUCIÓN
    // ============================================================

    state = ZombieState.chasing;

    _chasePlayer(dt);
  }

  // ============================================================
  // PERSEGUIR AL JUGADOR
  // ============================================================

  void _chasePlayer(double dt) {
    final direction = player.position - position;

    if (direction.length2 == 0) {
      return;
    }

    final normalizedDirection = direction.normalized();

    position += normalizedDirection * speed * dt;
  }

  // ============================================================
  // ATACAR AL JUGADOR
  // ============================================================

  void _attackPlayer() {
    // Si el jugador ya está muerto, no hacemos nada.
    if (player.stats.health <= 0) {
      return;
    }

    // Aplicamos el daño.
    player.stats.takeDamage(attackDamage);

    // Actualizamos inmediatamente el HUD.
    player.refreshHud();

    // Comprobamos si el jugador ha muerto.
    if (player.stats.health <= 0) {
      player.gameController.gameOver();
    }
  }

  // ============================================================
  // RECIBIR DAÑO
  // ============================================================

  void takeDamage(double damage) {
    // Un zombi muerto no puede recibir más daño.
    if (state == ZombieState.dead) {
      return;
    }

    health -= damage;

    // Evitamos valores negativos.
    if (health <= 0) {
      health = 0;

      state = ZombieState.dead;

      // El jugador obtiene experiencia por matar al zombi.
      player.gainExperience(xpReward);

      // Eliminamos el zombi del mundo.
      removeFromParent();
    }
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ============================================================
    // CUERPO
    // ============================================================

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2,
      paint,
    );

    // ============================================================
    // BORDE
    // ============================================================

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      size.x / 2 - 1,
      borderPaint,
    );

    // ============================================================
    // BARRA DE VIDA
    // ============================================================

    _renderHealthBar(canvas);
  }

  // ============================================================
  // BARRA DE VIDA
  // ============================================================

  void _renderHealthBar(Canvas canvas) {
    final backgroundPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final healthPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final barWidth = size.x + 4;

    const barHeight = 5.0;

    // Fondo de la barra.
    canvas.drawRect(
      Rect.fromLTWH(
        -2,
        -12,
        barWidth,
        barHeight,
      ),
      backgroundPaint,
    );

    // Porcentaje de vida.
    final healthPercentage = math.max(
      0.0,
      health / maxHealth,
    );

    // Vida restante.
    canvas.drawRect(
      Rect.fromLTWH(
        -2,
        -12,
        barWidth * healthPercentage,
        barHeight,
      ),
      healthPaint,
    );
  }
}