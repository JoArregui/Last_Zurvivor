import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../systems/rewards/reward.dart';
import '../../systems/rewards/reward_type.dart';
import '../../../core/theme/game_theme.dart';
import '../player/player.dart';
import '../space/space_sprites.dart';

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
    attackDamage: 10,
    attackCooldown: 0.8,
  ),

  fast(
    health: 50,
    speed: 120,
    size: 28,
    color: Colors.orange,
    xpReward: 20,
    attackDamage: 7,
    attackCooldown: 0.55,
  ),

  tank(
    health: 300,
    speed: 40,
    size: 50,
    color: Colors.purple,
    xpReward: 60,
    attackDamage: 25,
    attackCooldown: 1.2,
  );

  const ZombieType({
    required this.health,
    required this.speed,
    required this.size,
    required this.color,
    required this.xpReward,
    required this.attackDamage,
    required this.attackCooldown,
  });

  final double health;
  final double speed;
  final double size;
  final Color color;
  final double xpReward;
  final double attackDamage;
  final double attackCooldown;
}

class Zombie extends PositionComponent {
  Zombie({
    required Vector2 position,
    required this.player,
    this.type = ZombieType.normal,
    this.difficultyMultiplier = 1.0,
  }) : super(
          position: position,
          size: Vector2.all(type.size),
          anchor: Anchor.center,
        ) {
    // ==========================================================
    // ESTADÍSTICAS BASE + DIFICULTAD
    // ==========================================================

    maxHealth = type.health * difficultyMultiplier;

    health = maxHealth;

    speed = type.speed * _getSpeedMultiplier();

    xpReward = type.xpReward;

    color = _resolveThemeColor(type);

    attackDamage =
        type.attackDamage * _getDamageMultiplier();

    attackCooldown =
        type.attackCooldown / _getAttackSpeedMultiplier();

    // ==========================================================
    // VARIACIÓN INDIVIDUAL
    // ==========================================================

    _personalSpeedMultiplier =
        0.92 + _random.nextDouble() * 0.16;

    speed *= _personalSpeedMultiplier;

    // Cada zombi recibe un lado preferente para el movimiento
    // de cerco.
    _orbitDirection =
        _random.nextBool() ? 1.0 : -1.0;
  }

  final Player player;

  final ZombieType type;

  final double difficultyMultiplier;

  final math.Random _random = math.Random();

  // ============================================================
  // ESTADÍSTICAS
  // ============================================================

  late double health;

  late double maxHealth;

  late double speed;

  late double xpReward;

  late Color color;

  late double attackDamage;

  late double attackCooldown;

  // ============================================================
  // VARIACIÓN INDIVIDUAL
  // ============================================================

  late double _personalSpeedMultiplier;

  /// 1 = sentido horario
  /// -1 = sentido antihorario
  late double _orbitDirection;

  // ============================================================
  // ATAQUE
  // ============================================================

  /// Distancia a la que empieza a atacar.
  double attackRange = 40;

  double _attackTimer = 0;

  // ============================================================
  // MOVIMIENTO
  // ============================================================

  /// Tiempo hasta recalcular la dirección.
  double _directionTimer = 0;

  Vector2 _movementDirection = Vector2.zero();

  // ============================================================
  // SEPARACIÓN
  // ============================================================

  /// Distancia mínima que intentará mantener respecto a otros
  /// zombis.
  double separationRadius = 55;

  /// Fuerza de separación.
  double separationStrength = 1.4;

  // ============================================================
  // CERCO
  // ============================================================

  /// Distancia aproximada a la que los zombis intentan rodear
  /// al jugador.
  double surroundDistance = 65;

  /// A partir de esta distancia empezamos a favorecer el
  /// movimiento lateral.
  double surroundStartDistance = 180;

  // ============================================================
  // ESTADO
  // ============================================================

  ZombieState state = ZombieState.idle;

  // ============================================================
  // COLOR POR VARIANTE (motor comun, piel distinta)
  // ============================================================

  Color _resolveThemeColor(ZombieType zombieType) {
    final theme = GameThemes.current;
    switch (zombieType) {
      case ZombieType.normal:
        return theme.enemyNormalColor;
      case ZombieType.fast:
        return theme.enemyFastColor;
      case ZombieType.tank:
        return theme.enemyTankColor;
    }
  }

  /// Nombre narrativo segun variante (Caminante / Interceptor / Dron...).
  String get displayName {
    final theme = GameThemes.current;
    switch (type) {
      case ZombieType.normal:
        return theme.enemyNormalName;
      case ZombieType.fast:
        return theme.enemyFastName;
      case ZombieType.tank:
        return theme.enemyTankName;
    }
  }

  // ============================================================
  // MULTIPLICADORES DE DIFICULTAD
  // ============================================================

  double _getSpeedMultiplier() {
    switch (type) {
      case ZombieType.normal:
        return 1.0 +
            ((difficultyMultiplier - 1.0) * 0.25);

      case ZombieType.fast:
        return 1.0 +
            ((difficultyMultiplier - 1.0) * 0.35);

      case ZombieType.tank:
        return 1.0 +
            ((difficultyMultiplier - 1.0) * 0.15);
    }
  }

  double _getDamageMultiplier() {
    return 1.0 +
        ((difficultyMultiplier - 1.0) * 0.30);
  }

  double _getAttackSpeedMultiplier() {
    return 1.0 +
        ((difficultyMultiplier - 1.0) * 0.20);
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    // ----------------------------------------------------------
    // MUERTO
    // ----------------------------------------------------------

    if (state == ZombieState.dead) {
      return;
    }

    // ----------------------------------------------------------
    // JUGADOR MUERTO
    // ----------------------------------------------------------

    if (player.stats.health <= 0) {
      state = ZombieState.idle;
      return;
    }

    // ----------------------------------------------------------
    // DISTANCIA AL JUGADOR
    // ----------------------------------------------------------

    final distance =
        position.distanceTo(player.position);

    // ----------------------------------------------------------
    // ATAQUE
    // ----------------------------------------------------------

    if (distance <= attackRange) {
      state = ZombieState.attacking;

      _attackTimer -= dt;

      if (_attackTimer <= 0) {
        _attackPlayer();

        _attackTimer = attackCooldown;
      }

      return;
    }

    // ----------------------------------------------------------
    // PERSECUCIÓN
    // ----------------------------------------------------------

    state = ZombieState.chasing;

    _chasePlayer(dt);
  }

  // ============================================================
  // PERSEGUIR AL JUGADOR
  // ============================================================

  void _chasePlayer(double dt) {
    switch (type) {
      case ZombieType.normal:
        _normalMovement(dt);
        break;

      case ZombieType.fast:
        _fastMovement(dt);
        break;

      case ZombieType.tank:
        _tankMovement(dt);
        break;
    }
  }

  // ============================================================
  // MOVIMIENTO NORMAL
  // ============================================================

  void _normalMovement(double dt) {
    final toPlayer =
        player.position - position;

    if (toPlayer.length2 == 0) {
      return;
    }

    final distance = toPlayer.length;

    final direction =
        toPlayer.normalized();

    // ----------------------------------------------------------
    // MOVIMIENTO DE CERCO
    // ----------------------------------------------------------
    //
    // Cuando se aproxima al jugador, comienza a introducir
    // movimiento lateral.
    //

    Vector2 desiredDirection = direction;

    if (distance < surroundStartDistance) {
      final side = Vector2(
        -direction.y,
        direction.x,
      );

      final surroundFactor =
          1 -
          ((distance - surroundDistance) /
                  (surroundStartDistance -
                      surroundDistance))
              .clamp(0.0, 1.0);

      desiredDirection =
          (direction +
                  side *
                      (_orbitDirection *
                          surroundFactor *
                          0.65))
              .normalized();
    }

    // ----------------------------------------------------------
    // SEPARACIÓN
    // ----------------------------------------------------------

    final separation =
        _calculateSeparation();

    desiredDirection =
        (desiredDirection +
                separation * separationStrength)
            .normalized();

    // ----------------------------------------------------------
    // MOVER
    // ----------------------------------------------------------

    position +=
        desiredDirection * speed * dt;
  }

  // ============================================================
  // MOVIMIENTO FAST
  // ============================================================

  void _fastMovement(double dt) {
    _directionTimer -= dt;

    if (_directionTimer <= 0 ||
        _movementDirection.length2 == 0) {
      _directionTimer =
          0.18 +
          _random.nextDouble() * 0.30;

      final toPlayer =
          player.position - position;

      if (toPlayer.length2 == 0) {
        return;
      }

      final direction =
          toPlayer.normalized();

      // --------------------------------------------------------
      // MOVIMIENTO LATERAL
      // --------------------------------------------------------

      final side = Vector2(
        -direction.y,
        direction.x,
      );

      final variation =
          (_random.nextDouble() - 0.5) * 1.1;

      _movementDirection =
          (direction +
                  side *
                      (variation +
                          _orbitDirection * 0.35))
              .normalized();
    }

    // ----------------------------------------------------------
    // SEPARACIÓN
    // ----------------------------------------------------------

    final separation =
        _calculateSeparation();

    final finalDirection =
        (_movementDirection +
                separation *
                    (separationStrength * 1.2))
            .normalized();

    position +=
        finalDirection * speed * dt;
  }

  // ============================================================
  // MOVIMIENTO TANK
  // ============================================================

  void _tankMovement(double dt) {
    final toPlayer =
        player.position - position;

    if (toPlayer.length2 == 0) {
      return;
    }

    final direction =
        toPlayer.normalized();

    // El Tank se mueve principalmente hacia delante.
    //
    // La separación es menor para que tenga sensación de
    // "masa" y pueda presionar al jugador.

    final separation =
        _calculateSeparation();

    final finalDirection =
        (direction +
                separation *
                    (separationStrength * 0.45))
            .normalized();

    position +=
        finalDirection * speed * dt;
  }

  // ============================================================
  // SEPARACIÓN ENTRE ZOMBIS
  // ============================================================

  Vector2 _calculateSeparation() {
    final zombies =
        parent?.children.whereType<Zombie>();

    if (zombies == null || zombies.isEmpty) {
      return Vector2.zero();
    }

    Vector2 separation = Vector2.zero();

    int nearbyZombies = 0;

    for (final other in zombies) {
      // --------------------------------------------------------
      // NO COMPARARSE CONSIGO MISMO
      // --------------------------------------------------------

      if (identical(other, this)) {
        continue;
      }

      // --------------------------------------------------------
      // IGNORAR MUERTOS
      // --------------------------------------------------------

      if (other.state == ZombieState.dead) {
        continue;
      }

      final offset =
          position - other.position;

      final distance = offset.length;

      // --------------------------------------------------------
      // DEMASIADO CERCA
      // --------------------------------------------------------

      if (distance <= separationRadius &&
          distance > 0.01) {
        final strength =
            (separationRadius - distance) /
                separationRadius;

        separation +=
            offset.normalized() * strength;

        nearbyZombies++;
      }
    }

    if (nearbyZombies == 0) {
      return Vector2.zero();
    }

    return separation.normalized();
  }

  // ============================================================
  // ATAQUE
  // ============================================================

  void _attackPlayer() {
    if (player.stats.health <= 0) {
      return;
    }

    player.stats.takeDamage(
      attackDamage,
    );

    player.refreshHud();

    if (player.stats.health <= 0) {
      player.gameController.gameOver();
    }
  }

  // ============================================================
  // RECIBIR DAÑO
  // ============================================================

  void takeDamage(double damage) {
    if (state == ZombieState.dead) {
      return;
    }

    health -= damage;

    if (health <= 0) {
      health = 0;

      state = ZombieState.dead;

      // ========================================================
      // EXPERIENCIA
      // ========================================================

      player.gainExperience(
        xpReward,
      );

      // ========================================================
      // RECOMPENSA
      // ========================================================

      _tryDropReward();

      // ========================================================
      // ELIMINAR
      // ========================================================

      removeFromParent();
    }
  }

  // ============================================================
  // RECOMPENSAS
  // ============================================================

  void _tryDropReward() {
    final double rewardChance = GameThemes.current.rewardDropChance;

    if (_random.nextDouble() >
        rewardChance) {
      return;
    }

    final rewardType =
        RewardType.values[
          _random.nextInt(
            RewardType.values.length,
          )
        ];

    final reward = Reward(
      position: position.clone(),
      type: rewardType,
      player: player,
    );

    parent?.add(reward);
  }

  // ============================================================
  // RENDER
  // ============================================================

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // ==========================================================
    // NAVES ENEMIGAS (variante naves, Desktop/Espacio)
    // walker = Dron / runner = Interceptor / tank = Crucero
    // ==========================================================

    final ship = _spaceSprite();

    if (ship != null) {
      final toPlayer = player.position - position;
      final angle = toPlayer.length2 > 0.01
          ? math.atan2(toPlayer.y, toPlayer.x)
          : 0.0;

      // Dibujamos la nave mas grande que el hitbox para que
      // se aprecie el pixel-art (el combate sigue por distancia).
      final drawW = size.x * 2.1;
      final drawH = drawW * (ship.image.height / ship.image.width);
      final cx = size.x / 2;
      final cy = size.y / 2;

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      ship.render(
        canvas,
        position: Vector2(-drawW / 2, -drawH / 2),
        size: Vector2(drawW, drawH),
      );
      canvas.restore();
    } else {
      // ========================================================
      // CUERPO (resto de variantes)
      // ========================================================

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(
          size.x / 2,
          size.y / 2,
        ),
        size.x / 2,
        paint,
      );

      // ========================================================
      // BORDE
      // ========================================================

      final borderPaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(
        Offset(
          size.x / 2,
          size.y / 2,
        ),
        size.x / 2 - 1,
        borderPaint,
      );
    }

    // ==========================================================
    // VIDA
    // ==========================================================

    _renderHealthBar(canvas);
  }

  /// Sprite espacial segun tipo, o null fuera de la variante.
  Sprite? _spaceSprite() {
    if (!SpaceSprites.useSprites) return null;
    switch (type) {
      case ZombieType.normal:
        return SpaceSprites.walker;
      case ZombieType.fast:
        return SpaceSprites.runner;
      case ZombieType.tank:
        return SpaceSprites.tank;
    }
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

    final barWidth =
        size.x + 4;

    const barHeight = 5.0;

    // ----------------------------------------------------------
    // FONDO
    // ----------------------------------------------------------

    canvas.drawRect(
      Rect.fromLTWH(
        -2,
        -12,
        barWidth,
        barHeight,
      ),
      backgroundPaint,
    );

    // ----------------------------------------------------------
    // PORCENTAJE
    // ----------------------------------------------------------

    final healthPercentage =
        math.max(
          0.0,
          health / maxHealth,
        );

    // ----------------------------------------------------------
    // VIDA RESTANTE
    // ----------------------------------------------------------

    canvas.drawRect(
      Rect.fromLTWH(
        -2,
        -12,
        barWidth *
            healthPercentage,
        barHeight,
      ),
      healthPaint,
    );
  }
}