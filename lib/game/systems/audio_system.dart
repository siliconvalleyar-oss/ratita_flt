import 'dart:math';
import 'package:flame_audio/flame_audio.dart';

class AudioSystem {
  static bool _initialised = false;
  static int _lastScoreTime = 0;
  static int _activePlayers = 0;
  static const int _maxPlayers = 3;
  static AudioPlayer? _rainPlayer;

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

  static void pigSound() => _play('chancho_00.mp3', volume: 0.5);

  static void thunder() => _play('relampago_00.mp3', volume: 0.6);

  static void startRain() {
    if (!_initialised) return;
    stopRain();
    FlameAudio.play('lluvia_00.mp3', volume: 0.2).then((player) {
      _rainPlayer = player;
      player.setReleaseMode(ReleaseMode.loop);
    });
  }

  static void stopRain() {
    _rainPlayer?.stop();
    _rainPlayer?.dispose();
    _rainPlayer = null;
  }

  static void startCrickets() {
    if (!_initialised) return;
    FlameAudio.bgm.stop();
    final r = Random().nextBool();
    FlameAudio.bgm.play(r ? 'grillos_00.mp3' : 'grillos_01.mp3', volume: 0.15);
  }

  static void stopCrickets() {
    FlameAudio.bgm.stop();
  }

  static void stopAll() {
    stopRain();
    stopCrickets();
  }
}
