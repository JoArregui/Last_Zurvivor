import '../../components/player/player.dart';
import 'upgrade.dart';

class UpgradeService {
  static void applyUpgrade(
    Player player,
    UpgradeType upgrade,
  ) {
    switch (upgrade) {
      case UpgradeType.damage:
        player.stats.increaseDamage(0.20);
        break;

      case UpgradeType.movementSpeed:
        player.stats.increaseMovementSpeed(0.15);
        break;

      case UpgradeType.maxHealth:
        player.stats.increaseMaxHealth(30);
        break;

      case UpgradeType.attackSpeed:
        player.stats.increaseAttackSpeed(0.20);
        break;

      case UpgradeType.projectileSpeed:
        player.stats.increaseProjectileSpeed(0.20);
        break;
    }
  }
}