lib/
│
├── core/
│   └── constants/
│       └── game_constants.dart
│
├── game/
│   ├── models/
│   │   └── hud_data.dart
│   │
│   ├── components/
│   │   ├── player/
│   │   │   ├── player.dart
│   │   │   └── player_stats.dart
│   │   │
│   │   ├── enemies/
│   │   │   └── zombie.dart
│   │   │
│   │   ├── weapons/
│   │   │   ├── weapon.dart
│   │   │   └── projectile.dart
│   │   │
│   │   └── world/
│   │       └── game_world.dart
│   │
│   ├── systems/
│   │   ├── enemy_spawner.dart
│   │   └── progression/
│   │       ├── player_progression.dart
│   │       ├── upgrade.dart
│   │       └── upgrade_service.dart
│   │
│   ├── game_controller.dart
│   ├── game_state.dart
│   └── last_survivor_game.dart
│
├── presentation/
│   └── widgets/
│       ├── game_hud.dart
│       └── level_up_overlay.dart
│
└── main.dart