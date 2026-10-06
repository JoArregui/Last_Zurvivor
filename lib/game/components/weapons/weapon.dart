import 'package:flame/components.dart';

import '../enemies/zombie.dart';
import '../player/player.dart';
import '../../../core/theme/game_theme.dart';
import 'projectile.dart';

class Weapon extends Component {
  Weapon({
    required this.player,
  });

  final Player player;

  // ============================================================
  // CONFIGURACIÓN DEL ARMA
  // ============================================================

  final double baseDamage = 25;

  double fireRate = 0.5;

  double get range => GameThemes.current.weaponRange;

  double _fireTimer = 0;

  // ============================================================
  // UPDATE
  // ============================================================

  @override
  void update(double dt) {
    super.update(dt);

    _fireTimer -= dt;

    if (_fireTimer > 0) {
      return;
    }

    final target = _findNearestZombie();

    if (target == null) {
      return;
    }

    // ============================================================
    // COMPROBAR DISTANCIA
    // ============================================================

    final distance =
        player.position.distanceTo(target.position);

    if (distance > range) {
      return;
    }

    // ============================================================
    // DISPARAR
    // ============================================================

    _shoot(target);

    _fireTimer =
        fireRate / player.stats.attackSpeedMultiplier;
  }

  // ============================================================
  // BUSCAR EL ZOMBI MÁS CERCANO
  // ============================================================

  Zombie? _findNearestZombie() {
    final zombies =
        player.parent?.children.whereType<Zombie>();

    if (zombies == null || zombies.isEmpty) {
      return null;
    }

    Zombie? nearest;

    double nearestDistance = double.infinity;

    // ============================================================
    // CÁMARA
    // ============================================================

    final game = player.findGame();

    if (game == null) {
      return null;
    }

    final camera = game.camera;

    // ============================================================
    // RECORRER ZOMBIS
    // ============================================================

    for (final zombie in zombies) {
      // ----------------------------------------------------------
      // IGNORAR ZOMBIS MUERTOS
      // ----------------------------------------------------------

      if (zombie.state == ZombieState.dead) {
        continue;
      }

      // ----------------------------------------------------------
      // SOLO ZOMBIS VISIBLES EN PANTALLA
      // ----------------------------------------------------------

      if (!camera.canSee(zombie)) {
        continue;
      }

      // ----------------------------------------------------------
      // DISTANCIA AL JUGADOR
      // ----------------------------------------------------------

      final distance =
          player.position.distanceTo(zombie.position);

      // ----------------------------------------------------------
      // BUSCAR EL MÁS CERCANO
      // ----------------------------------------------------------

      if (distance < nearestDistance) {
        nearestDistance = distance;
        nearest = zombie;
      }
    }

    return nearest;
  }

  // ============================================================
  // DISPARAR
  // ============================================================

  void _shoot(Zombie target) {
    final direction =
        target.position - player.position;

    final projectile = Projectile(
  position: player.position.clone(),
  direction: direction,
  damage: baseDamage * player.stats.damageMultiplier,
  speed: 500 * player.stats.projectileSpeedMultiplier,
);

    player.parent?.add(projectile);
  }
}