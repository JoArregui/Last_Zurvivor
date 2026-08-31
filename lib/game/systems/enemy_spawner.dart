import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemies/zombie.dart';
import '../components/player/player.dart';
import '../../core/constants/game_constants.dart';
import 'difficulty_director.dart';

class EnemySpawner extends Component {
  EnemySpawner({
    required this.player,
    required this.world,
  });

  final Player player;
  final Component world;

  final Random _random = Random();

  // ===============================================================
  // DIRECTOR DE DIFICULTAD
  // ===============================================================

  final DifficultyDirector difficultyDirector =
      DifficultyDirector();

  // ===============================================================
  // PROGRESIÓN INTERNA
  // ===============================================================

  int currentWave = 1;

  int _zombiesToSpawn = 0;

  int _zombiesSpawned = 0;

  bool _waveActive = false;

  // ===============================================================
  // TEMPORIZADORES INTERNOS
  // ===============================================================

  double _spawnTimer = 0;

  double _cooldownTimer = 0;

  // ===============================================================
  // LOAD
  // ===============================================================

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    startWave();
  }

  // ===============================================================
  // INICIAR OLEADA
  // ===============================================================

  void startWave() {
    _zombiesToSpawn =
        difficultyDirector.zombiesPerWave(currentWave);

    _zombiesSpawned = 0;

    _spawnTimer = 0.5;

    _waveActive = true;
  }

  // ===============================================================
  // UPDATE
  // ===============================================================

  @override
  void update(double dt) {
    super.update(dt);

    // =============================================================
    // JUGADOR MUERTO
    // =============================================================

    if (player.stats.health <= 0) {
      return;
    }

    // =============================================================
    // DESCANSO ENTRE OLEADAS
    // =============================================================

    if (!_waveActive) {
      _cooldownTimer -= dt;

      if (_cooldownTimer <= 0) {
        _nextWave();
      }

      return;
    }

    // =============================================================
    // LÍMITE DE ZOMBIS SIMULTÁNEOS
    // =============================================================

    if (activeZombies >=
        difficultyDirector.maxActiveZombies(currentWave)) {
      return;
    }

    // =============================================================
    // GENERACIÓN DE ZOMBIS
    // =============================================================

    if (_zombiesSpawned < _zombiesToSpawn) {
      _spawnTimer -= dt;

      if (_spawnTimer <= 0) {
        _spawnZombie();

        _zombiesSpawned++;

        _spawnTimer =
            difficultyDirector.spawnInterval(currentWave);
      }

      return;
    }

    // =============================================================
    // COMPROBAR SI LA OLEADA HA TERMINADO
    // =============================================================

    if (activeZombies == 0) {
      _waveActive = false;

      _cooldownTimer =
          difficultyDirector.waveCooldown(currentWave);
    }
  }

  // ===============================================================
  // ZOMBIS ACTIVOS
  // ===============================================================

  int get activeZombies {
    return world.children
        .whereType<Zombie>()
        .where(
          (zombie) =>
              zombie.state != ZombieState.dead,
        )
        .length;
  }

  // ===============================================================
  // SIGUIENTE OLEADA
  // ===============================================================

  void _nextWave() {
    currentWave++;

    startWave();
  }

  // ===============================================================
  // GENERAR ZOMBI
  // ===============================================================

  void _spawnZombie() {
    final spawnPosition = _getSpawnPosition();

    // =============================================================
    // SELECCIONAR TIPO
    // =============================================================

    final selectedType =
        difficultyDirector.selectZombieType(
      currentWave,
      _random,
    );

    // =============================================================
    // CREAR ZOMBI
    // =============================================================

    final zombie = Zombie(
      position: spawnPosition,
      player: player,
      type: selectedType,
      difficultyMultiplier:
          difficultyDirector.difficultyMultiplier(currentWave),
    );

    world.add(zombie);
  }

  // ===============================================================
  // POSICIÓN DE SPAWN
  // ===============================================================

  Vector2 _getSpawnPosition() {
    // El zombi nunca aparece demasiado cerca del jugador.
    const minimumDistance = 650.0;

    // Distancia adicional aleatoria.
    const maximumAdditionalDistance = 500.0;

    final angle =
        _random.nextDouble() * 2 * pi;

    final distance =
        minimumDistance +
        _random.nextDouble() *
            maximumAdditionalDistance;

    var x =
        player.position.x +
        cos(angle) * distance;

    var y =
        player.position.y +
        sin(angle) * distance;

    // =============================================================
    // LIMITAR AL MAPA
    // =============================================================

    x = x.clamp(
      50.0,
      GameConstants.worldWidth - 50.0,
    );

    y = y.clamp(
      50.0,
      GameConstants.worldHeight - 50.0,
    );

    return Vector2(x, y);
  }
}