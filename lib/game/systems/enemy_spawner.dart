import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemies/zombie.dart';
import '../components/player/player.dart';
import '../../core/constants/game_constants.dart';

class EnemySpawner extends Component {
  EnemySpawner({required this.player, required this.world});

  final Player player;
  final Component world;

  final Random _random = Random();

  // ============================================================
  // CONFIGURACIÓN DE LAS OLEADAS
  // ============================================================

  int currentWave = 1;

  int zombiesPerWave = 5;

  double timeBetweenSpawns = 1.0;

  double _spawnTimer = 1.0;

  int _zombiesToSpawn = 0;

  int _zombiesSpawned = 0;

  bool _waveActive = false;

  // ============================================================
  // DESCANSO ENTRE OLEADAS
  // ============================================================

  final double waveCooldown = 2.0;

  double _cooldownTimer = 0.0;

  // ============================================================
  // INFORMACIÓN PARA EL HUD
  // ============================================================

  /// Número total de zombis que tiene la oleada.
  int get totalZombies => _zombiesToSpawn;

  /// Número de zombis que ya han aparecido.
  int get zombiesSpawned => _zombiesSpawned;

  /// Número de zombis que todavía deben aparecer.
  int get zombiesRemainingToSpawn {
    final remaining = _zombiesToSpawn - _zombiesSpawned;

    return remaining < 0 ? 0 : remaining;
  }

  /// Número de zombis vivos actualmente.
  int get activeZombies {
    return world.children
        .whereType<Zombie>()
        .where((zombie) => zombie.state != ZombieState.dead)
        .length;
  }

  /// Número total de zombis que quedan para completar la oleada.
  ///
  /// Incluye:
  /// - zombis que todavía no han aparecido
  /// - zombis que siguen vivos
  int get zombiesLeft {
    return zombiesRemainingToSpawn + activeZombies;
  }

  /// Indica si actualmente se está generando una oleada.
  bool get waveActive => _waveActive;

  /// Tiempo restante del descanso entre oleadas.
  double get cooldownRemaining {
    if (_cooldownTimer < 0) {
      return 0;
    }

    return _cooldownTimer;
  }

  // ============================================================
  // LOAD
  // ============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    startWave();
  }

  // ============================================================
  // INICIAR OLEADA
  // ============================================================

  void startWave() {
    _zombiesToSpawn = zombiesPerWave;

    _zombiesSpawned = 0;

    _spawnTimer = 1.0;

    _waveActive = true;
  }

  // ============================================================
  // UPDATE
  // ============================================================

  @override
void update(double dt) {
  super.update(dt);

  // ============================================================
  // DESCANSO ENTRE OLEADAS
  // ============================================================

  if (!_waveActive) {
    _cooldownTimer -= dt;

    _updatePlayerHud();

    if (_cooldownTimer <= 0) {
      _nextWave();
    }

    return;
  }

  // ============================================================
  // GENERACIÓN DE ZOMBIS
  // ============================================================

  if (_zombiesSpawned < _zombiesToSpawn) {
    _spawnTimer -= dt;

    if (_spawnTimer <= 0) {
      _spawnZombie();

      _zombiesSpawned++;

      _spawnTimer = timeBetweenSpawns;
    }

    _updatePlayerHud();

    return;
  }

  // ============================================================
  // COMPROBAR ZOMBIS VIVOS
  // ============================================================

  final activeZombies = world.children
      .whereType<Zombie>()
      .where(
        (zombie) =>
            zombie.state != ZombieState.dead,
      );

  // ============================================================
  // ACTUALIZAR HUD
  // ============================================================

  _updatePlayerHud();

  // ============================================================
  // TERMINAR OLEADA
  // ============================================================

  if (activeZombies.isEmpty) {
    _waveActive = false;

    _cooldownTimer = waveCooldown;

    _updatePlayerHud();
  }
}

  void _updatePlayerHud() {
    player.updateWaveInfo(wave: currentWave, zombies: zombiesLeft);
  }

  // ============================================================
  // SIGUIENTE OLEADA
  // ============================================================

  void _nextWave() {
    currentWave++;

    // ============================================================
    // ESCALADO DE DIFICULTAD
    // ============================================================

    // +3 zombis por oleada.
    zombiesPerWave += 3;

    // Generación ligeramente más rápida.
    if (timeBetweenSpawns > 0.2) {
      timeBetweenSpawns *= 0.95;
    }

    startWave();
  }

  // ============================================================
  // GENERAR ZOMBI
  // ============================================================

  void _spawnZombie() {
    final spawnPosition = _getSpawnPosition();

    // ============================================================
    // SELECCIONAR TIPO DE ZOMBI
    // ============================================================

    ZombieType selectedType = ZombieType.normal;

    final rand = _random.nextDouble();

    // A partir de la oleada 3:
    // 25% de posibilidades de Tank.
    if (currentWave >= 3 && rand < 0.25) {
      selectedType = ZombieType.tank;
    }
    // A partir de la oleada 2:
    // 25% de posibilidades de Fast.
    else if (currentWave >= 2 && rand < 0.50) {
      selectedType = ZombieType.fast;
    }

    // El resto son normales.

    // ============================================================
    // CREAR ZOMBI
    // ============================================================

    final zombie = Zombie(
      position: spawnPosition,
      player: player,
      type: selectedType,
    );

    world.add(zombie);
  }

  // ============================================================
  // POSICIÓN DE APARICIÓN
  // ============================================================

  Vector2 _getSpawnPosition() {
    // El zombi aparece como mínimo a esta distancia
    // del jugador.
    const minimumDistance = 600.0;

    // Distancia adicional aleatoria.
    const maximumAdditionalDistance = 500.0;

    final angle = _random.nextDouble() * 2 * pi;

    final distance =
        minimumDistance + _random.nextDouble() * maximumAdditionalDistance;

    var x = player.position.x + cos(angle) * distance;

    var y = player.position.y + sin(angle) * distance;

    // ============================================================
    // LIMITAR AL MAPA
    // ============================================================

    x = x.clamp(50.0, GameConstants.worldWidth - 50.0);

    y = y.clamp(50.0, GameConstants.worldHeight - 50.0);

    return Vector2(x, y);
  }
}
