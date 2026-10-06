import 'package:flutter/material.dart';

/// Identificador de variante tematica.
///
/// El motor (Flame + spawner + progresion + mundo) es comun.
/// Cada variante solo cambia [GameTheme]: colores, nombres,
/// lore y ajustes de velocidad.
enum GameVariantId {
  zombies,
  planes,
  space,
}

/// Tema visual + narrativo + tuning por variante.
///
/// Pensado para que las 3 ramas (`variante-zombies`,
/// `variante-aviones`, `variante-naves-espaciales`) reutilicen
/// el 100% del motor y solo cambien `GameThemes.current`.
@immutable
class GameTheme {
  const GameTheme({
    required this.id,
    required this.appTitle,
    required this.subtitle,
    required this.lore,
    required this.playerLabel,
    required this.enemyLabelSingular,
    required this.enemyLabelPlural,
    required this.playerColor,
    required this.playerBorderColor,
    required this.projectileColor,
    required this.worldBackground,
    required this.enemyNormalColor,
    required this.enemyFastColor,
    required this.enemyTankColor,
    required this.enemyNormalName,
    required this.enemyFastName,
    required this.enemyTankName,
    required this.playerSpeed,
    required this.weaponRange,
    required this.rewardDropChance,
  });

  final GameVariantId id;
  final String appTitle;
  final String subtitle;
  final String lore;
  final String playerLabel;
  final String enemyLabelSingular;
  final String enemyLabelPlural;

  final Color playerColor;
  final Color playerBorderColor;
  final Color projectileColor;
  final Color worldBackground;

  final Color enemyNormalColor;
  final Color enemyFastColor;
  final Color enemyTankColor;

  final String enemyNormalName;
  final String enemyFastName;
  final String enemyTankName;

  /// Tuning de jugabilidad por variante.
  final double playerSpeed;
  final double weaponRange;
  final double rewardDropChance;
}

/// Registro de temas + tema activo.
///
/// Cambiar de variante = asignar otro tema:
/// ```dart
/// GameThemes.current = GameThemes.planes;
/// ```
class GameThemes {
  GameThemes._();

  // ------------------------------------------------------------
  // 1) ZOMBIES (base original del proyecto)
  // ------------------------------------------------------------

  static const zombies = GameTheme(
    id: GameVariantId.zombies,
    appTitle: 'Last Survivor: Zombies',
    subtitle: 'Sobrevive al apocalipsis',
    lore:
        'La ciudad ha caido. Oleadas de zombies te rodean, '
        'solo tu punteria y tus mejoras te mantendran con vida.',
    playerLabel: 'Superviviente',
    enemyLabelSingular: 'zombie',
    enemyLabelPlural: 'zombies',
    playerColor: Colors.blue,
    playerBorderColor: Colors.white,
    projectileColor: Colors.yellow,
    worldBackground: Color(0xFF4A6741),
    enemyNormalColor: Colors.red,
    enemyFastColor: Colors.orange,
    enemyTankColor: Colors.purple,
    enemyNormalName: 'Caminante',
    enemyFastName: 'Corredor',
    enemyTankName: 'Tanque',
    playerSpeed: 200.0,
    weaponRange: 500.0,
    rewardDropChance: 0.15,
  );

  // ------------------------------------------------------------
  // 2) AVIONES (combate aereo)
  // ------------------------------------------------------------

  static const planes = GameTheme(
    id: GameVariantId.planes,
    appTitle: 'Last Survivor: Aviones',
    subtitle: 'As de la aviacion',
    lore:
        'Surcas un cielo en guerra. Escuadrones enemigos te interceptan, '
        'recoge suministros en pleno vuelo y mejora tu caza.',
    playerLabel: 'Caza aliado',
    enemyLabelSingular: 'avion enemigo',
    enemyLabelPlural: 'aviones enemigos',
    playerColor: Color(0xFF1565C0),
    playerBorderColor: Color(0xFFB3E5FC),
    projectileColor: Color(0xFFFFEB3B),
    worldBackground: Color(0xFF87B5D6),
    enemyNormalColor: Color(0xFFB71C1C),
    enemyFastColor: Color(0xFFEF6C00),
    enemyTankColor: Color(0xFF4A148C),
    enemyNormalName: 'Interceptor',
    enemyFastName: 'Caza ligero',
    enemyTankName: 'Bombardero pesado',
    playerSpeed: 260.0,
    weaponRange: 600.0,
    rewardDropChance: 0.15,
  );

  // ------------------------------------------------------------
  // 3) NAVES ESPACIALES
  // ------------------------------------------------------------

  static const space = GameTheme(
    id: GameVariantId.space,
    appTitle: 'Last Survivor: Naves',
    subtitle: 'Ultimo piloto de la flota',
    lore:
        'A la deriva en un sector hostil. Drones y cruceros alienigenas '
        'te acosan, captura nucleos de energia y sobrevive al vacio.',
    playerLabel: 'Interceptor estelar',
    enemyLabelSingular: 'nave enemiga',
    enemyLabelPlural: 'naves enemigas',
    playerColor: Color(0xFF00E5FF),
    playerBorderColor: Colors.white,
    projectileColor: Color(0xFF76FF03),
    worldBackground: Color(0xFF0B1026),
    enemyNormalColor: Color(0xFFFF3D00),
    enemyFastColor: Color(0xFFFFAB00),
    enemyTankColor: Color(0xFFAA00FF),
    enemyNormalName: 'Dron',
    enemyFastName: 'Interceptor espectral',
    enemyTankName: 'Crucero',
    playerSpeed: 240.0,
    weaponRange: 650.0,
    rewardDropChance: 0.18,
  );

  /// Tema activo. Rama VARIANTE-AVIONES.
  static GameTheme current = planes;

  static GameTheme byId(GameVariantId id) {
    switch (id) {
      case GameVariantId.zombies:
        return zombies;
      case GameVariantId.planes:
        return planes;
      case GameVariantId.space:
        return space;
    }
  }
}
