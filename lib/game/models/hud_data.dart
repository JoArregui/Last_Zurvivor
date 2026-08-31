class HudData {
  const HudData({
    required this.level,
    required this.experience,
    required this.experienceToNextLevel,
    required this.health,
    required this.maxHealth,
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