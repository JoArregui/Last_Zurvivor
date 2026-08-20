class PlayerStats {
  double maxHealth = 100;

  double health = 100;

  double movementSpeed = 200;

  double damageMultiplier = 1.0;

  double attackSpeedMultiplier = 1.0;

  double projectileSpeedMultiplier = 1.0;

  double pickupRange = 100;

  void increaseMaxHealth(double amount) {
    maxHealth += amount;
    health += amount;
  }

  void heal(double amount) {
    health += amount;

    if (health > maxHealth) {
      health = maxHealth;
    }
  }

  void takeDamage(double amount) {
    health -= amount;

    if (health < 0) {
      health = 0;
    }
  }

  void increaseDamage(double percentage) {
    damageMultiplier += percentage;
  }

  void increaseAttackSpeed(double percentage) {
    attackSpeedMultiplier += percentage;
  }

  void increaseMovementSpeed(double percentage) {
    movementSpeed *= 1 + percentage;
  }

  void increaseProjectileSpeed(double percentage) {
    projectileSpeedMultiplier += percentage;
  }
}