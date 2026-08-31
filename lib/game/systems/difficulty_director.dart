import 'dart:math';

import '../components/enemies/zombie.dart';

/// ===============================================================
/// DIRECTOR DE DIFICULTAD
/// ===============================================================
///
/// Se encarga de calcular cómo aumenta la dificultad del juego
/// a medida que avanzan las oleadas.
///
/// Responsabilidades:
/// - Escalar vida de los zombis.
/// - Escalar velocidad.
/// - Escalar daño.
/// - Escalar cantidad de zombis.
/// - Escalar frecuencia de aparición.
/// - Determinar el límite de zombis simultáneos.
/// - Determinar qué tipos de zombis pueden aparecer.
///
/// El jugador NO tiene acceso a esta información.
/// Es un sistema completamente interno del juego.
///
class DifficultyDirector {
  DifficultyDirector({
    this.startingWave = 1,
  });

  // ===============================================================
  // CONFIGURACIÓN BASE
  // ===============================================================

  /// Oleada desde la que comienza el director.
  final int startingWave;

  /// Máximo multiplicador general de dificultad.
  static const double maxDifficultyMultiplier = 3.0;

  /// Número base de zombis de la primera oleada.
  static const int baseZombiesPerWave = 5;

  /// Aumento de zombis por oleada.
  static const int zombiesIncreasePerWave = 3;

  /// Tiempo base entre apariciones.
  static const double baseSpawnInterval = 1.0;

  /// Tiempo mínimo entre apariciones.
  static const double minimumSpawnInterval = 0.25;

  /// Tiempo máximo entre oleadas.
  static const double baseWaveCooldown = 2.0;

  // ===============================================================
  // MULTIPLICADOR GLOBAL
  // ===============================================================

  /// Multiplicador global de dificultad.
  ///
  /// Oleada 1 = 1.00
  /// Oleada 2 = 1.08
  /// Oleada 3 = 1.16
  /// ...
  ///
  /// Se limita a 3.0 para evitar que los valores crezcan
  /// indefinidamente.
  double difficultyMultiplier(int wave) {
    final normalizedWave = max(
      1,
      wave,
    );

    final waveFactor =
        (normalizedWave - startingWave) * 0.08;

    return (1.0 + waveFactor).clamp(
      1.0,
      maxDifficultyMultiplier,
    );
  }

  // ===============================================================
  // CANTIDAD DE ZOMBIS
  // ===============================================================

  /// Cantidad total de zombis que tendrá una oleada.
  ///
  /// Oleada 1 = 5
  /// Oleada 2 = 8
  /// Oleada 3 = 11
  /// ...
  int zombiesPerWave(int wave) {
    final normalizedWave = max(
      1,
      wave,
    );

    return baseZombiesPerWave +
        ((normalizedWave - 1) *
            zombiesIncreasePerWave);
  }

  // ===============================================================
  // LÍMITE DE ZOMBIS SIMULTÁNEOS
  // ===============================================================

  /// Número máximo de zombis vivos simultáneamente.
  ///
  /// Esto evita que una oleada grande genere cientos de enemigos
  /// al mismo tiempo.
  ///
  /// Oleada 1 = 8
  /// Oleada 2 = 10
  /// Oleada 3 = 12
  /// ...
  ///
  /// Máximo = 40.
  int maxActiveZombies(int wave) {
    final normalizedWave = max(
      1,
      wave,
    );

    final value =
        8 + ((normalizedWave - 1) * 2);

    return value.clamp(
      8,
      40,
    );
  }

  // ===============================================================
  // INTERVALO DE SPAWN
  // ===============================================================

  /// Calcula el tiempo entre apariciones de zombis.
  ///
  /// A medida que aumenta la dificultad aparecen más rápidamente.
  double spawnInterval(int wave) {
    final difficulty =
        difficultyMultiplier(wave);

    final interval =
        baseSpawnInterval / difficulty;

    return interval.clamp(
      minimumSpawnInterval,
      baseSpawnInterval,
    );
  }

  // ===============================================================
  // COOLDOWN ENTRE OLEADAS
  // ===============================================================

  /// Tiempo de descanso entre oleadas.
  ///
  /// El descanso se reduce progresivamente, pero nunca desaparece
  /// completamente.
  double waveCooldown(int wave) {
    final normalizedWave = max(
      1,
      wave,
    );

    final reduction =
        (normalizedWave - 1) * 0.05;

    return (baseWaveCooldown - reduction)
        .clamp(
          0.75,
          baseWaveCooldown,
        );
  }

  // ===============================================================
  // VIDA DEL ZOMBI
  // ===============================================================

  /// Multiplicador de vida para un zombi.
  double healthMultiplier(int wave) {
    final difficulty =
        difficultyMultiplier(wave);

    // Escalado algo más agresivo que la dificultad general.
    return 1.0 + ((difficulty - 1.0) * 0.75);
  }

  // ===============================================================
  // VELOCIDAD DEL ZOMBI
  // ===============================================================

  /// Multiplicador de velocidad.
  ///
  /// La velocidad aumenta más lentamente que la vida para evitar
  /// que los zombis terminen siendo imposibles de esquivar.
  double speedMultiplier(int wave) {
    final difficulty =
        difficultyMultiplier(wave);

    return 1.0 + ((difficulty - 1.0) * 0.35);
  }

  // ===============================================================
  // DAÑO DEL ZOMBI
  // ===============================================================

  /// Multiplicador del daño.
  double damageMultiplier(int wave) {
    final difficulty =
        difficultyMultiplier(wave);

    return 1.0 + ((difficulty - 1.0) * 0.60);
  }

  // ===============================================================
  // XP
  // ===============================================================

  /// Multiplicador de experiencia.
  ///
  /// La experiencia aumenta ligeramente para compensar la mayor
  /// dificultad.
  double xpMultiplier(int wave) {
    final difficulty =
        difficultyMultiplier(wave);

    return 1.0 + ((difficulty - 1.0) * 0.40);
  }

  // ===============================================================
  // TIPO DE ZOMBI
  // ===============================================================

  /// Selecciona aleatoriamente el tipo de zombi disponible
  /// en una determinada oleada.
  ///
  /// Oleada 1:
  ///   100% normal
  ///
  /// Oleada 2:
  ///   25% fast
  ///   75% normal
  ///
  /// Oleada 3+:
  ///   15% tank
  ///   30% fast
  ///   55% normal
  ZombieType selectZombieType(
    int wave,
    Random random,
  ) {
    final normalizedWave = max(
      1,
      wave,
    );

    final rand = random.nextDouble();

    // =============================================================
    // OLEADA 1
    // =============================================================

    if (normalizedWave == 1) {
      return ZombieType.normal;
    }

    // =============================================================
    // OLEADA 2
    // =============================================================

    if (normalizedWave == 2) {
      if (rand < 0.25) {
        return ZombieType.fast;
      }

      return ZombieType.normal;
    }

    // =============================================================
    // OLEADA 3+
    // =============================================================

    if (rand < 0.15) {
      return ZombieType.tank;
    }

    if (rand < 0.45) {
      return ZombieType.fast;
    }

    return ZombieType.normal;
  }

  // ===============================================================
  // ESTADÍSTICAS COMPLETAS DEL ZOMBI
  // ===============================================================

  /// Devuelve las estadísticas calculadas para un determinado
  /// tipo de zombi y oleada.
  ///
  /// Esta función permite que Zombie reciba todos sus valores
  /// ya calculados por el director.
  ZombieDifficulty getZombieDifficulty({
    required ZombieType type,
    required int wave,
  }) {
    final health =
        type.health *
        healthMultiplier(wave);

    final speed =
        type.speed *
        speedMultiplier(wave);

    final damage =
        10.0 *
        damageMultiplier(wave);

    final xp =
        type.xpReward *
        xpMultiplier(wave);

    return ZombieDifficulty(
      health: health,
      speed: speed,
      attackDamage: damage,
      xpReward: xp,
    );
  }
}

/// ===============================================================
/// ESTADÍSTICAS DE DIFICULTAD DE UN ZOMBI
/// ===============================================================
///
/// Objeto inmutable que contiene los valores calculados por
/// DifficultyDirector.
///
/// De esta manera Zombie no necesita conocer las fórmulas de
/// dificultad.
///
class ZombieDifficulty {
  const ZombieDifficulty({
    required this.health,
    required this.speed,
    required this.attackDamage,
    required this.xpReward,
  });

  final double health;

  final double speed;

  final double attackDamage;

  final double xpReward;
}