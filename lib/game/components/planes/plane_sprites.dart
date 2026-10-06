import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import '../../../core/theme/game_theme.dart';

/// Cargador central de sprites de la variante de aviones.
///
/// Imagenes originales en `Desktop/Aviones` (JPG sin alfa),
/// procesadas a `assets/images/planes/*.png` con fondo eliminado
/// por segmentacion (rembg/u2net).
///
/// Solo se usa cuando el tema activo es [GameVariantId.planes];
/// en el resto de variantes devuelve null y el motor dibuja
/// primitivas de Canvas como antes.
///
/// NOTA: todos los aviones miran hacia arriba (-Y), asi que la
/// rotacion hacia una direccion `d` es `atan2(d.y, d.x) + pi/2`.
class PlaneSprites {
  PlaneSprites._();

  static bool _loading = false;
  static bool _loaded = false;

  static Sprite? player;
  static Sprite? walker;
  static Sprite? runner;
  static Sprite? tank;
  static Sprite? bullet;
  static Sprite? coin;
  static Sprite? heart;

  /// Oceano en mosaico (sin transparencia, JPG original).
  static ui.Image? backgroundTile;

  static bool get useSprites =>
      GameThemes.current.id == GameVariantId.planes;

  /// Carga diferida, idempotente y tolerante a fallos:
  /// si un asset falta, el juego sigue con primitivas.
  static Future<void> ensureLoaded() async {
    if (_loaded || _loading || !useSprites) return;
    _loading = true;
    try {
      player = await _sprite('planes/player.png');
      walker = await _sprite('planes/walker.png');
      runner = await _sprite('planes/runner.png');
      tank = await _sprite('planes/tank.png');
      bullet = await _sprite('planes/bullet.png');
      coin = await _sprite('planes/coin.png');
      heart = await _sprite('planes/heart.png');
      backgroundTile =
          await Flame.images.load('planes/background_tile.jpg');
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
