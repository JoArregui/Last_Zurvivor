import 'dart:math';

import 'package:flame/components.dart';

import '../components/enemies/zombie.dart';
import '../components/player/player.dart';
import '../../core/constants/game_constants.dart';

class EnemySpawner extends Component {
  EnemySpawner({
    required this.player,
    required this.world,
  });

  final Player player;
  final Component world;

  final Random _random = Random();

  int currentWave = 1;

  int zombiesPerWave = 5;

  double timeBetweenSpawns = 1.0;

  double _spawnTimer = 1.0;

  int _zombiesToSpawn = 0;

  int _zombiesSpawned = 0;

  bool _waveActive = false;

  // Tiempo opcional de descanso entre oleadas
  final double waveCooldown = 2.0;
  double _cooldownTimer = 0.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    startWave();
  }

  void startWave() {
    _zombiesToSpawn = zombiesPerWave;
    _zombiesSpawned = 0;
    _spawnTimer = 1.0;
    _waveActive = true;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // ============================================================
    // SI LA OLEADA NO ESTÁ ACTIVA, ESPERAMOS EL COOLDOWN PARA LA SIGUIENTE
    // ============================================================
    if (!_waveActive) {
      _cooldownTimer -= dt;
      if (_cooldownTimer <= 0) {
        _nextWave();
      }
      return;
    }

    // ============================================================
    // FASE 1: GENERACIÓN DE ZOMBIS DE LA OLEADA ACTUAL
    // ============================================================
    if (_zombiesSpawned < _zombiesToSpawn) {
      _spawnTimer -= dt;

      if (_spawnTimer <= 0) {
        _spawnZombie();
        _zombiesSpawned++;
        _spawnTimer = timeBetweenSpawns;
      }
      return;
    }

    // ============================================================
    // FASE 2: COMPROBAR SI QUEDAN ZOMBIS VIVOS EN EL MAPA
    // ============================================================
    final activeZombies = world.children.whereType<Zombie>().where(
          (z) => z.state != ZombieState.dead,
        );

    // Si ya nacieron todos y no queda ninguno vivo en el mundo, termina la oleada
    if (activeZombies.isEmpty) {
      _waveActive = false;
      _cooldownTimer = waveCooldown;
    }
  }

  void _nextWave() {
    currentWave++;
    
    // Escalado de dificultad: +3 zombis por oleada y generación ligeramente más rápida
    zombiesPerWave += 3;
    if (timeBetweenSpawns > 0.2) {
      timeBetweenSpawns *= 0.95;
    }

    startWave();
  }

  void _spawnZombie() {
  final spawnPosition = _getSpawnPosition();

  // Seleccionar tipo de zombi según probabilidades o número de oleada
  ZombieType selectedType = ZombieType.normal;

  final rand = _random.nextDouble();
  if (currentWave >= 3 && rand < 0.25) {
    selectedType = ZombieType.tank;
  } else if (currentWave >= 2 && rand < 0.5) {
    selectedType = ZombieType.fast;
  }

  final zombie = Zombie(
    position: spawnPosition,
    player: player,
    type: selectedType,
  );

  world.add(zombie);
}

  Vector2 _getSpawnPosition() {
    const minimumDistance = 600.0;

    final angle = _random.nextDouble() * 2 * pi;

    final distance = minimumDistance + _random.nextDouble() * 500;

    var x = player.position.x + cos(angle) * distance;
    var y = player.position.y + sin(angle) * distance;

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