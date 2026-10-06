import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../../core/theme/game_theme.dart';

/// Cargador central de sprites de la variante zombie.
///
/// Imagenes originales en `Desktop/Zombies` (JPG sin alfa),
/// procesadas a `assets/images/zombies/*.png` con fondo eliminado
/// por segmentacion (rembg/u2net): el flood-fill por color no sirve
/// aqui porque los personajes son oscuros como el fondo.
///
/// Solo se usa cuando el tema activo es [GameVariantId.zombies];
/// en el resto de variantes devuelve null y el motor dibuja
/// primitivas de Canvas como antes.
class ZombieSprites {
  ZombieSprites._();

  static bool _loading = false;
  static bool _loaded = false;

  static Sprite? player;
  static Sprite? walker;
  static Sprite? runner;
  static Sprite? tank;
  static Sprite? bullet;
  static Sprite? coin;
  static Sprite? heart;

  /// Asfalto agrietado en mosaico (sin transparencia, JPG original).
  static ui.Image? backgroundTile;

  static bool get useSprites =>
      GameThemes.current.id == GameVariantId.zombies;

  /// Carga diferida, idempotente y tolerante a fallos:
  /// si un asset falta, el juego sigue con primitivas.
  static Future<void> ensureLoaded() async {
    if (_loaded || _loading || !useSprites) return;
    _loading = true;
    try {
      player = await _sprite('zombies/player.png');
      walker = await _sprite('zombies/walker.png');
      runner = await _sprite('zombies/runner.png');
      tank = await _sprite('zombies/tank.png');
      bullet = await _sprite('zombies/bullet.png');
      coin = await _sprite('zombies/coin.png');
      heart = await _sprite('zombies/heart.png');
      backgroundTile =
          await Flame.images.load('zombies/background_tile.jpg');
      _loaded = true;
    } catch (_) {
      // Fallback a primitivas: no romper el juego por un asset.
      _loaded = false;
    } finally {
      _loading = false;
    }
  }

  static Future<Sprite?> _sprite(String path) async {
    try {
      final image = await Flame.images.load(path);
      return Sprite(image);
    } catch (_) {
      return null;
    }
  }
}
