class HudData {
  final int level;
  final double experience;
  final double experienceToNextLevel;
  final double health;
  final double maxHealth;

  const HudData({
    required this.level,
    required this.experience,
    required this.experienceToNextLevel,
    required this.health,
    required this.maxHealth,
  });

  double get experienceProgress {
    if (experienceToNextLevel == 0) return 0;

    return experience / experienceToNextLevel;
  }

  double get healthProgress {
    if (maxHealth == 0) return 0;

    return health / maxHealth;
  }
}