import 'dart:math';
import 'package:flame_audio/flame_audio.dart';

class AudioSystem {
  static bool _initialised = false;
  static int _lastScoreTime = 0;
  static int _activePlayers = 0;
  static const int _maxPlayers = 3;
  static String? _currentCricket;
  static bool _cricketPaused = false;
  static String? _currentRain;
  static bool _rainPaused = false;

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
      'relampago_01.mp3',
    ]);
    _initialised = true;
  }

  static void _play(String file, {double volume = 0.5}) {
    if (!_initialised || _activePlayers >= _maxPlayers) return;
    _activePlayers++;
    FlameAudio.play(file, volume: volume).then((_) {
      _activePlayers--;
    }, onError: (_) {
      _activePlayers--;
    });
  }

  static void jump() => _play('jump.wav', volume: 0.5);
  static void death() => _play('death.wav', volume: 0.6);

  static void score() {
    if (!_initialised) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastScoreTime > 0 && now - _lastScoreTime < 150) return;
    _lastScoreTime = now;
    _play('score.wav', volume: 0.3);
  }

  static void milestone() => _play('milestone.wav', volume: 0.5);

  static void chickenSound() {
    final r = Random().nextBool();
    _play(r ? 'gallina_00.mp3' : 'gallina_01.mp3', volume: 0.4);
  }

  static void pigSound() {
    _play('chancho_00.mp3', volume: 0.5);
  }

  static void startCrickets() {
    if (!_initialised) return;
    stopCrickets();
    final r = Random().nextBool();
    _currentCricket = r ? 'grillos_00.mp3' : 'grillos_01.mp3';
    FlameAudio.bgm.play(
      _currentCricket!,
      volume: 0.15,
    );
  }

  static void stopCrickets() {
    if (_currentCricket != null) {
      FlameAudio.bgm.stop();
      _currentCricket = null;
    }
  }

  static void pauseAll() {
    if (_currentCricket != null) {
      FlameAudio.bgm.pause();
      _cricketPaused = true;
    }
  }

  static void resumeAll() {
    if (_cricketPaused && _currentCricket != null) {
      FlameAudio.bgm.resume();
      _cricketPaused = false;
    }
    if (_rainPaused && _currentRain != null) {
      FlameAudio.bgm.resume();
      _rainPaused = false;
    }
  }

  static void startRain() {
    if (!_initialised) return;
    stopRain();
    _currentRain = 'lluvia_00.mp3';
    FlameAudio.bgm.play(_currentRain!, volume: 0.25);
  }

  static void stopRain() {
    if (_currentRain != null) {
      FlameAudio.bgm.stop();
      _currentRain = null;
    }
  }

  static void thunder() {
    final r = Random().nextBool();
    _play(r ? 'relampago_00.mp3' : 'relampago_01.mp3', volume: 0.6);
  }

  static void pauseRain() {
    if (_currentRain != null) {
      FlameAudio.bgm.pause();
      _rainPaused = true;
    }
  }

  static void resumeRain() {
    if (_rainPaused && _currentRain != null) {
      FlameAudio.bgm.resume();
      _rainPaused = false;
    }
  }
}
