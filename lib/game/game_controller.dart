import 'package:flutter/foundation.dart';

import 'components/player/player.dart';
import 'game_state.dart';
import 'models/hud_data.dart';
import 'last_survivor_game.dart';

class GameController extends ChangeNotifier {
  GameState state = GameState.playing;

  Player? player;

  LastSurvivorGame? game;

  int level = 1;

  HudData _hud = const HudData(
    level: 1,
    experience: 0,
    experienceToNextLevel: 100,
    health: 100,
    maxHealth: 100,
  );

  HudData get hud => _hud;

  bool get isPlaying => state == GameState.playing;

  bool get isLevelUp => state == GameState.levelUp;

  bool get isPaused => state == GameState.paused;

  bool get isGameOver => state == GameState.gameOver;

  void updateHud({
    required int level,
    required double experience,
    required double experienceToNextLevel,
    required double health,
    required double maxHealth,
    required int wave,
    required int zombiesRemaining,
  }) {
    _hud = HudData(
      level: level,
      experience: experience,
      experienceToNextLevel: experienceToNextLevel,
      health: health,
      maxHealth: maxHealth,
      wave: wave,
      zombiesRemaining: zombiesRemaining,
    );

    notifyListeners();
  }

  void showLevelUpScreen(int newLevel) {
    level = newLevel;
    state = GameState.levelUp;
    notifyListeners();
  }

  void hideLevelUpScreen() {
    state = GameState.playing;
    notifyListeners();
  }

  void pauseGame() {
    if (state != GameState.playing) return;

    state = GameState.paused;
    notifyListeners();
  }

  void resumeGame() {
    if (state != GameState.paused) return;

    state = GameState.playing;
    notifyListeners();
  }

  void gameOver() {
    state = GameState.gameOver;
    notifyListeners();
  }

  void restartGame() {
    state = GameState.playing;

    level = 1;

    _hud = const HudData(
      level: 1,
      experience: 0,
      experienceToNextLevel: 100,
      health: 100,
      maxHealth: 100,
    );

    player = null;

    notifyListeners();
  }
}
