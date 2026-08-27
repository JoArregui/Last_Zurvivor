class HudData {
  const HudData({
    required this.level,
    required this.experience,
    required this.experienceToNextLevel,
    required this.health,
    required this.maxHealth,
    this.wave = 1,
    this.zombiesRemaining = 0,
  });

  // ============================================================
  // JUGADOR
  // ============================================================

  final int level;

  final double experience;

  final double experienceToNextLevel;

  final double health;

  final double maxHealth;

  // ============================================================
  // OLEADA
  // ============================================================

  /// Oleada actual.
  final int wave;

  /// Número de zombis que quedan para completar la oleada.
  final int zombiesRemaining;

  // ============================================================
  // PROGRESO DE EXPERIENCIA
  // ============================================================

  double get experienceProgress {
    if (experienceToNextLevel <= 0) {
      return 0;
    }

    return (experience / experienceToNextLevel)
        .clamp(0.0, 1.0);
  }

  // ============================================================
  // PROGRESO DE VIDA
  // ============================================================

  double get healthProgress {
    if (maxHealth <= 0) {
      return 0;
    }

    return (health / maxHealth)
        .clamp(0.0, 1.0);
  }
}