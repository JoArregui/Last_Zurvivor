import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../../core/theme/game_theme.dart';

/// Cargador central de sprites de la variante espacial.
///
/// Imagenes originales en `Desktop/Espacio` (JPG sin alfa),
/// procesadas a `assets/images/space/*.png` con fondo eliminado
/// por flood-fill desde bordes (ver `assets/README` en commit).
///
/// Solo se usa cuando el tema activo es [GameVariantId.space];
/// en el resto de variantes devuelve null y el motor dibuja
/// primitivas de Canvas como antes.
class SpaceSprites {
  SpaceSprites._();

  static bool _loading = false;
  static bool _loaded = false;

  static Sprite? player;
  static Sprite? walker;
  static Sprite? runner;
  static Sprite? tank;
  static Sprite? bullet;
  static Sprite? coin;
  static Sprite? heart;

  /// Fondo estelar en mosaico (sin transparencia, JPG original).
  static ui.Image? backgroundTile;

  static bool get useSprites =>
      GameThemes.current.id == GameVariantId.space;

  /// Carga diferida, idempotente y tolerante a fallos:
  /// si un asset falta, el juego sigue con primitivas.
  static Future<void> ensureLoaded() async {
    if (_loaded || _loading || !useSprites) return;
    _loading = true;
    try {
      player = await _sprite('space/player.png');
      walker = await _sprite('space/walker.png');
      runner = await _sprite('space/runner.png');
      tank = await _sprite('space/tank.png');
      bullet = await _sprite('space/bullet.png');
      coin = await _sprite('space/coin.png');
      heart = await _sprite('space/heart.png');
      backgroundTile =
          await Flame.images.load('space/background_tile.jpg');
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
