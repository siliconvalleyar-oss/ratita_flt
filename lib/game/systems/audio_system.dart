import 'dart:math';
import 'package:flame_audio/flame_audio.dart';

class AudioSystem {
  static bool _initialised = false;
  static int _lastScoreTime = 0;
  static bool _cricketsPlaying = false;
  static bool _rainPlaying = false;

  static Future<void> init() async {
    if (_initialised) return;
    FlameAudio.audioCache.prefix = 'assets/images/audio/';
    await FlameAudio.audioCache.loadAll([
      'jump.wav',
      'death.wav',
      'score.wav',
      'milestone.wav',
      'grillos_00.mp3',
      'grillos_01.mp3',
      'gallina_00.mp3',
      'gallina_01.mp3',
      'chancho_00.mp3',
      'lluvia_00.mp3',
      'relampago_00.mp3',
    ]);
    _initialised = true;
  }

  static void jump() {
    if (!_initialised) return;
    try {
      FlameAudio.play('jump.wav', volume: 0.5);
    } catch (_) {}
  }

  static void death() {
    if (!_initialised) return;
    try {
      FlameAudio.play('death.wav', volume: 0.6);
    } catch (_) {}
  }

  static void thunder() {
    if (!_initialised) return;
    try {
      FlameAudio.play('relampago_00.mp3', volume: 0.8);
    } catch (_) {}
  }

  static void score() {
    if (!_initialised) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastScoreTime > 0 && now - _lastScoreTime < 150) return;
    _lastScoreTime = now;
    try {
      FlameAudio.play('score.wav', volume: 0.3);
    } catch (_) {}
  }

  static void milestone() {
    if (!_initialised) return;
    try {
      FlameAudio.play('milestone.wav', volume: 0.5);
    } catch (_) {}
  }

  static void chickenSound() {
    if (!_initialised) return;
    try {
      FlameAudio.play(Random().nextBool() ? 'gallina_00.mp3' : 'gallina_01.mp3',
          volume: 0.4);
    } catch (_) {}
  }

  static void pigSound() {
    if (!_initialised) return;
    try {
      FlameAudio.play('chancho_00.mp3', volume: 0.5);
    } catch (_) {}
  }

  static void startRain() {
    if (!_initialised) return;
    if (_rainPlaying) return;
    _rainPlaying = true;
    FlameAudio.bgm.stop();
    _cricketsPlaying = false;
    FlameAudio.bgm.play('lluvia_00.mp3', volume: 0.5);
  }

  static void stopRain() {
    if (!_initialised) return;
    _rainPlaying = false;
    FlameAudio.bgm.stop();
  }

  static void startCrickets() {
    if (!_initialised) return;
    if (_cricketsPlaying) return;
    _cricketsPlaying = true;
    FlameAudio.bgm.stop();
    _rainPlaying = false;
    FlameAudio.bgm.play(
        Random().nextBool() ? 'grillos_00.mp3' : 'grillos_01.mp3',
        volume: 0.4);
  }

  static void stopCrickets() {
    if (!_initialised) return;
    _cricketsPlaying = false;
    FlameAudio.bgm.stop();
  }

  static void stopAll() {
    if (!_initialised) return;
    _cricketsPlaying = false;
    _rainPlaying = false;
    FlameAudio.bgm.stop();
  }
}
