# Last Survivor — Motor + 3 variantes

> ✈️ RAMA ACTIVA: `variante-aviones` — Combate aereo (Interceptor / Caza ligero / Bombardero).
> Tema: `GameThemes.planes` (playerSpeed 260, range 600, fondo cielo `0xFF87B5D6`).
> Jugador: caza aliado, proyectiles trazadoras; enemigos mas rapidos, ideal para joystick.

Juego **survivors-like** en Flutter + Flame: oleadas, progresion, recompensas,
niebla de guerra, minimapa y HUD en Flutter.

El proyecto esta disenado como **motor comun + piel tematica**:
el 100% de la logica (game-loop, spawner, dificultad, armas, progresion,
mundo) se reutiliza y cada variante solo cambia `GameTheme`.

## Variantes (ramas)

| Rama | Tema activo | Fantasia |
|---|---|---|
| `main` | `GameThemes.zombies` | Zombies (base original) |
| `variante-zombies` | `GameThemes.zombies` | Apocalipsis enriquecido (docs + tuning zombie) |
| `variante-aviones` | `GameThemes.planes` | Combate aereo: caza aliado vs interceptores/bombarderos |
| `variante-naves-espaciales` | `GameThemes.space` | Espacio: interceptor estelar vs drones/cruceros |

Cambiar de variante = 1 linea:

```dart
// lib/core/theme/game_theme.dart
GameThemes.current = GameThemes.planes; // o .zombies / .space
```

Cada rama fija su tema en el commit inicial y ajusta
`README` + tuning propio sin tocar el motor.

## Stack

- `flutter` + `flame: ^1.38.0` (game-loop, `FlameGame`, `PositionComponent`, `Camera`, `Joystick`)
- `provider: ^6.1.5` como puente Flame -> Flutter UI (`GameController extends ChangeNotifier`)
- Sin assets externos: todo el render es `Canvas` primitivo (`drawCircle`, `drawRect`, `TextPaint`)

## Estructura

```text
lib/
├── core/
│   ├── constants/game_constants.dart   # tamano mundo (3000x3000), fallback velocidad
│   └── theme/game_theme.dart           # ★ motor tematico: zombies / aviones / naves
├── game/
│   ├── game_controller.dart            # puente Flame->Flutter (HUD, levelUp, gameOver)
│   ├── game_state.dart                 # playing / levelUp / paused / gameOver
│   ├── last_survivor_game.dart         # FlameGame: mundo+jugar+joystick+spawner+fog+minimap
│   ├── models/hud_data.dart            # datos inmutables HUD
│   ├── components/
│   │   ├── player/player.dart          # movimiento, XP, render (color por tema)
│   │   ├── player/player_stats.dart    # vida/dano/velocidades
│   │   ├── enemies/zombie.dart         # IA normal/fast/tank + cerco + separacion
│   │   ├── weapons/weapon.dart         # auto-disparo al enemigo visible mas cercano
│   │   ├── weapons/projectile.dart     # colision manual r<25
│   │   └── world/
│   │       ├── game_world.dart         # fondo por tema + 4 POIs
│   │       ├── map_point_of_interest.dart
│   │       ├── fog_of_war.dart         # grid 120x120, vision r=150
│   │       └── minimap.dart            # viewport fijo 180px
│   ├── systems/
│   │   ├── enemy_spawner.dart          # oleadas 5+3*(w-1), throttle max activos
│   │   ├── difficulty_director.dart    # mult 1.0+(w-1)*0.08 cap 3.0
│   │   ├── progression/                # player_progression, upgrade, upgrade_service
│   │   └── rewards/                    # reward, reward_type, reward_popup
├── presentation/widgets/               # game_hud, level_up_overlay, game_over_overlay
└── main.dart                           # titulo por tema + Stack GameWidget/HUD/Overlays
```

## Flujo de juego

```text
Joystick -> LastSurvivorGame.update: player.move(delta)
  -> Player.update: position += velocity*dt (clamp mundo)
  -> Weapon.update: cada 0.5/atkSpeed busca Zombie visible mas cercano (range por tema)
  -> Projectile: avanza, si dist<25 -> Zombie.takeDamage
  -> Zombie muerto: player.gainExperience(xp) + 15-18% drop Reward
  -> PlayerProgression: next *= 1.25, onLevelUp -> stop + showLevelUpScreen
  -> Flutter LevelUpOverlay -> UpgradeService (+20% dano / +15% vel / +30 vida)
  -> EnemySpawner: oleadas con DifficultyDirector
  -> Zombie ataca (r<=40): takeDamage -> refreshHud -> si 0 -> gameOver()
  -> GameOverOverlay -> restartGame() + nuevo FlameGame
Paralelo: FogOfWar (r=150) + POIs (r=110) dropean Reward una vez + Minimap.
```

## GameTheme (como crear tu variante)

Campos: `appTitle, lore, playerColor, projectileColor, worldBackground,`
`enemyNormal/Fast/TankColor + Name, playerSpeed, weaponRange, rewardDropChance`.

1. Anade un preset en `GameThemes` (copia `planes`/`space`).
2. Asigna `GameThemes.current = tuTema;`
3. Ajusta solo tuning/narrativa. No dupliques logica.

| Tema | playerSpeed | weaponRange | drop | Fondo |
|---|---|---|---|---|
| zombies | 200 | 500 | 0.15 | `0xFF4A6741` verde |
| aviones | 260 | 600 | 0.15 | `0xFF87B5D6` cielo |
| naves | 240 | 650 | 0.18 | `0xFF0B1026` espacio |

## Comandos

```powershell
flutter pub get
flutter analyze
flutter run -d windows   # o chrome / android
flutter test
```

## Ramas y trabajo realizado

- `main`: motor + `GameTheme` + docs base (este README).
- `variante-zombies`: fija `GameThemes.zombies`, tuning apocalipsis.
- `variante-aviones`: fija `GameThemes.planes`, lore aereo.
- `variante-naves-espaciales`: fija `GameThemes.space`, lore espacial.

Ver `git branch -a` y `git log --oneline --graph --all`.
