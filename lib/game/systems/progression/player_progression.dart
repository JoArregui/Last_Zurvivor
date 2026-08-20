class PlayerProgression {
  int level = 1;

  double experience = 0;

  double experienceToNextLevel = 100;

  void Function()? onLevelUp;

  bool addExperience(double amount) {
    experience += amount;

    bool leveledUp = false;

    while (experience >= experienceToNextLevel) {
      experience -= experienceToNextLevel;

      level++;

      experienceToNextLevel *= 1.25;

      leveledUp = true;
    }

    if (leveledUp) {
      onLevelUp?.call();
    }

    return leveledUp;
  }

  double get experienceProgress {
    return experience / experienceToNextLevel;
  }
}