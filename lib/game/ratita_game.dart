import 'dart:math';
import 'package:flutter/painting.dart';
import 'package:flame/game.dart';
import 'package:ratita_runner/game/components/player.dart';
import 'package:ratita_runner/game/components/enemy.dart';
import 'package:ratita_runner/game/components/friend.dart';
import 'package:ratita_runner/game/components/ground.dart';
import 'package:ratita_runner/game/systems/score_system.dart';
import 'package:ratita_runner/game/systems/audio_system.dart';

enum GameScreenState { menu, playing, gameOver }

class RatitaGame extends FlameGame {
  late Player _player;
  late Ground _ground;
  late ScoreSystem _scoreSystem;
  final List<Enemy> _enemies = [];
  final List<Friend> _friends = [];
  double _spawnTimer = 0;
  double _friendTimer = 0;
  GameScreenState _screenState = GameScreenState.menu;
  final Random _random = Random();
  bool _inCampoLaJuanita = false;
  int _lastMilestoneScore = 0;
  double _gameTime = 0;
  bool _isNight = false;
  bool _isRaining = false;
  double _thunderTimer = 0;
  double _flashAlpha = 0;

  VoidCallback? onStateChanged;

  static const double groundY = 340;
  static const double viewportW = 900;
  static const double viewportH = 400;
  static const double playerX = 100;
  static const int campoLaJuanitaThreshold = 300;
  static const int celebrationDuration = 2;

  bool get isPlaying => _screenState == GameScreenState.playing;
  bool get isGameOver => _screenState == GameScreenState.gameOver;
  bool get isMenu => _screenState == GameScreenState.menu;
  bool get inCampoLaJuanita => _inCampoLaJuanita;
  ScoreSystem get scoreSystem => _scoreSystem;

  @override
  Color backgroundColor() => const Color(0xFF87CEEB);

  @override
  Future<void> onLoad() async {
    _scoreSystem = ScoreSystem();
    _player = Player();
    _ground = Ground();
    add(_ground);
    add(_player);
  }

  void handleTap() {
    if (_screenState == GameScreenState.playing) {
      _player.jump();
    }
  }

  void startGame() {
    _screenState = GameScreenState.playing;
    _inCampoLaJuanita = false;
    _lastMilestoneScore = 0;
    _scoreSystem.reset();
    _enemies.clear();
    _friends.clear();
    _spawnTimer = 2.0;
    _friendTimer = 10.0;
    _gameTime = 0;
    _isNight = false;
    _isRaining = false;
    _thunderTimer = 0;
    _flashAlpha = 0;
    AudioSystem.stopCrickets();
    AudioSystem.stopRain();
    removeAll(children);
    _player = Player();
    _ground = Ground();
    add(_ground);
    add(_player);
    _player.goToRunning();
    onStateChanged?.call();
  }

  void endGame() {
    _screenState = GameScreenState.gameOver;
    _player.die();
    _scoreSystem.checkHighScore();
    AudioSystem.stopCrickets();
    AudioSystem.stopRain();
    AudioSystem.death();
    onStateChanged?.call();
  }

  void goToMenu() {
    _screenState = GameScreenState.menu;
    _inCampoLaJuanita = false;
    AudioSystem.stopCrickets();
    AudioSystem.stopRain();
    removeAll(children);
    _player = Player();
    _ground = Ground();
    add(_ground);
    add(_player);
    onStateChanged?.call();
  }

  void _spawnEnemy() {
    final enemy = Enemy.random(_scoreSystem.speed, _random);
    _enemies.add(enemy);
    add(enemy);
    if (enemy.type == EnemyType.pig) {
      AudioSystem.pigSound();
    } else if (enemy.type == EnemyType.walkingChicken ||
        enemy.type == EnemyType.eatingChicken ||
        enemy.type == EnemyType.standingChicken) {
      AudioSystem.chickenSound();
    }
  }

  void _spawnFriend() {
    final friend = Friend(_random);
    _friends.add(friend);
    add(friend);
  }

  @override
  void update(double dt) {
    dt = dt.clamp(0, 0.05);
    super.update(dt);

    if (_screenState == GameScreenState.menu) {
      _player.updateMenuAnimation(dt);
      return;
    }

    if (_screenState == GameScreenState.gameOver) return;

    _scoreSystem.update(dt);

    _gameTime += dt;

    // night every 40 seconds: 0-40 day, 40-80 night, 80-120 day, etc
    final cyclePos = _gameTime % 80.0;
    final wasNight = _isNight;
    if (cyclePos >= 40 && cyclePos < 80) {
      _isNight = true;
      final nightFade = ((cyclePos - 40) / 10).clamp(0.0, 1.0);
      _ground.setNightProgress(nightFade);
    } else {
      _isNight = false;
      if (cyclePos < 10) {
        _ground.setNightProgress(1.0 - cyclePos / 10);
      } else if (cyclePos >= 70) {
        _ground.setNightProgress((cyclePos - 70) / 10);
      } else {
        _ground.setNightProgress(0.0);
      }
    }

    // start rain when night starts
    if (_isNight && !wasNight) {
      _isRaining = true;
      _ground.setRaining(true);
      AudioSystem.startRain();
      AudioSystem.startCrickets();
      _thunderTimer = _random.nextDouble() * 3 + 1;
    } else if (!_isNight && wasNight) {
      _isRaining = false;
      _ground.setRaining(false);
      AudioSystem.stopRain();
      AudioSystem.stopCrickets();
    }

    // thunder during rain
    if (_isRaining) {
      _thunderTimer -= dt;
      if (_thunderTimer <= 0) {
        AudioSystem.thunder();
        _flashAlpha = 1.0;
        _ground.triggerBolt();
        _thunderTimer = _random.nextDouble() * 5 + 2;
      }
    }

    // flash fade
    if (_flashAlpha > 0) {
      _flashAlpha = (_flashAlpha - dt * 3).clamp(0.0, 1.0);
    }

    _checkCampoLaJuanita();
    _checkMilestones();

    _player.updateRunningAnimation(dt);
    _player.updatePhysics(dt);

    _spawnTimer -= dt;
    if (_spawnTimer <= 0) {
      _spawnTimer = _random.nextDouble() * 2.5 + 0.8;
      _spawnEnemy();
    }

    _friendTimer -= dt;
    if (_friendTimer <= 0) {
      _friendTimer = _random.nextDouble() * 10 + 8;
      _spawnFriend();
    }

    for (final e in _enemies) {
      e.move(_scoreSystem.speed, dt);
    }
    _enemies.removeWhere((e) {
      if (e.isOffScreen) {
        e.removeFromParent();
        return true;
      }
      return false;
    });

    for (final f in _friends) {
      f.move(_scoreSystem.speed, dt);
    }
    _friends.removeWhere((f) {
      if (f.isOffScreen) {
        f.removeFromParent();
        return true;
      }
      return false;
    });

    for (final e in _enemies) {
      if (!e.passed && e.x + e.width < playerX) {
        e.passed = true;
        _scoreSystem.score += 10;
        AudioSystem.score();
        _player.celebrate();
      }
    }

    _checkCollisions();
  }

  void _checkCampoLaJuanita() {
    if (_scoreSystem.score >= campoLaJuanitaThreshold && !_inCampoLaJuanita) {
      _inCampoLaJuanita = true;
      AudioSystem.startCrickets();
    }
  }

  void _checkMilestones() {
    final milestones = [100, 200, 500, 1000, 2000];
    for (final m in milestones) {
      if (_scoreSystem.score >= m && _lastMilestoneScore < m) {
        _lastMilestoneScore = m;
        AudioSystem.milestone();
      }
    }
  }

  void _checkCollisions() {
    final playerBox = _player.hitbox;

    for (int i = _enemies.length - 1; i >= 0; i--) {
      final e = _enemies[i];
      if (playerBox.overlaps(e.hitbox)) {
        if (_player.hasShield) {
          _player.hasShield = false;
          e.removeFromParent();
          _enemies.removeAt(i);
          return;
        } else {
          endGame();
          return;
        }
      }
    }

    for (int i = _friends.length - 1; i >= 0; i--) {
      final f = _friends[i];
      if (playerBox.overlaps(f.hitbox)) {
        _player.hasShield = true;
        f.removeFromParent();
        _friends.removeAt(i);
        return;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // lightning flash overlay
    if (_flashAlpha > 0) {
      final flashPaint = Paint()..color = Color.fromARGB((_flashAlpha * 180).round(), 255, 255, 255);
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), flashPaint);
    }

    if (_screenState == GameScreenState.playing) {
      const textStyle = TextStyle(
        fontSize: 22,
        color: Color(0xFF6B4226),
        fontFamily: 'monospace',
        fontWeight: FontWeight.bold,
      );

      if (scoreSystem.highScore > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: 'HI ${scoreSystem.highScore.toString().padLeft(5, '0')}',
            style: textStyle,
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(size.x - tp.width - 10, 14));
      }

      final tp2 = TextPainter(
        text: TextSpan(
          text: scoreSystem.score.toString().padLeft(5, '0'),
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp2.paint(canvas, Offset(size.x - tp2.width - 10, 42));

      if (_inCampoLaJuanita) {
        const campStyle = TextStyle(
          fontSize: 14,
          color: Color(0xFF2E7D32),
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        );
        final tp3 = TextPainter(
          text: const TextSpan(text: 'Campo La Juanita', style: campStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp3.paint(canvas, const Offset(10, 14));
      }
    }
  }
}
