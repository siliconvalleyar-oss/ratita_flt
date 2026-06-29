import 'dart:math';
import 'dart:ui';
import 'package:flutter/painting.dart';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

enum PlayerState { menu, running, jumping, dead, celebrating, exploding, projectileForward, projectileInPlace, projectileReturn }

class Player extends PositionComponent {
  PlayerState _state = PlayerState.menu;
  double velocityY = 0;
  double _frameTimer = 0;
  int _frameIndex = 0;
  bool hasShield = false;
  double _shieldTimer = 0;
  int lives = 5;
  double _menuBounceTimer = 0;
  double _menuBounceOffset = 0;
  double _celebrationTimer = 0;
  int _celebrationFrame = 0;
  double _walkCycleTimer = 0;
  bool _isWalking = true;
  static const double _walkCycleDuration = 1.5;
  static const double _stopDuration = 0.6;
  static const double _playerW = 80;
  static const double _playerH = 120;

  int _jumpCount = 0;
  double _startX = 0;

  Sprite? _spriteArmOpen;
  Sprite? _spriteArmCrossed;
  Sprite? _spriteWalk0;
  Sprite? _spriteWalk1;
  Sprite? _spriteWalk2;
  Sprite? _spriteWalk3;
  Sprite? _spriteWalk4;
  Sprite? _spriteJump;
  Sprite? _spriteFront;
  Sprite? _spriteCelebrate0;
  Sprite? _spriteCelebrate1;
  Sprite? _spriteCelebrate2;
  Sprite? _spriteImpact;
  Sprite? _spriteFrases;

  bool _useSprites = false;
  bool get hasSprites => _useSprites;
  bool get isExploding => _state == PlayerState.exploding;

  final List<List<double>> _particles = [];
  double _phraseTimer = 0;
  String _currentPhrase = '';
  int _lastPhraseIdx = -1;
  Sprite? get frasesSprite => _spriteFrases;
  double get phraseTimer => _phraseTimer;
  String get currentPhrase => _currentPhrase;

  static final Paint _shieldStroke = Paint()
    ..color = const Color(0x554488FF)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  static final Paint _shieldFill = Paint()
    ..color = const Color(0x2244AAFF)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

  static const List<String> _phrases = [
    'Mi Chiquitaa!', 'La Gladys', 'La Nancy', 'Una rata', 'Mi Boquita',
    'Soy tacaño', 'No tengo un Mango', 'Ayudame tanque', 'Jugame la quinela',
    'No hay plata', 'A parar', 'Es una Hermosura el perrito', 'Jorge',
    'Mi negra', 'Un sapo', 'La Jirafa', 'Agarre las 4 cifras', 'Al peletin',
  ];

  Player() : super(size: Vector2(_playerW, _playerH));

  @override
  Future<void> onLoad() async {
    final results = await Future.wait([
      _load('ratita_brazo_abierto.png'),
      _load('ratita_brazo_cruzado.png'),
      _load('ratita_caminando_derecha_00.png'),
      _load('ratita_caminando_derecha_01.png'),
      _load('ratita_caminando_derecha_02.png'),
      _load('ratita_caminando_derecha_03.png'),
      _load('ratita_caminando_derecha_04.png'),
      _load('ratita_saltando.png'),
      _load('ratita_caminando_frente.png'),
      _load('ratita_festejando_00.png'),
      _load('ratita_festejando_01.png'),
      _load('ratita_festejando_02.png'),
      _load('impact_00.png'),
      _load('frases.png'),
    ]);

    _spriteArmOpen = results[0];
    _spriteArmCrossed = results[1];
    _spriteWalk0 = results[2];
    _spriteWalk1 = results[3];
    _spriteWalk2 = results[4];
    _spriteWalk3 = results[5];
    _spriteWalk4 = results[6];
    _spriteJump = results[7];
    _spriteFront = results[8];
    _spriteCelebrate0 = results[9];
    _spriteCelebrate1 = results[10];
    _spriteCelebrate2 = results[11];
    _spriteImpact = results[12];
    _spriteFrases = results[13];

    if (_spriteJump != null || _spriteFront != null) _useSprites = true;
    x = RatitaGame.playerX;
    y = RatitaGame.groundY - height;
  }

  Future<Sprite?> _load(String filename) async {
    try { return await Sprite.load('ratita/$filename'); } catch (_) { return null; }
  }

  Rect get hitbox => Rect.fromLTWH(x + 8, y + 8, width - 16, height - 16);

  bool get isProjectile => _state == PlayerState.projectileForward ||
      _state == PlayerState.projectileInPlace || _state == PlayerState.projectileReturn;

  void jump() {
    if (_state == PlayerState.dead || _state == PlayerState.exploding) return;
    if (_state == PlayerState.projectileInPlace) { _startReturn(); return; }
    if (isProjectile) return;
    if (_state == PlayerState.jumping) return;
    _jumpCount++;
    _state = PlayerState.jumping;
    velocityY = -16;
    final rng = Random();
    int idx;
    do { idx = rng.nextInt(_phrases.length); } while (idx == _lastPhraseIdx && _phrases.length > 1);
    _lastPhraseIdx = idx;
    _currentPhrase = _phrases[idx];
    _phraseTimer = 2.5;
  }

  void _startForward() {
    _startX = RatitaGame.playerX;
    _state = PlayerState.projectileForward;
    velocityY = -22;
  }

  void _startInPlace() { _state = PlayerState.projectileInPlace; velocityY = -18; }

  void _startReturn() {
    _state = PlayerState.projectileReturn;
    velocityY = -24;
  }

  void die() { _state = PlayerState.dead; }

  bool loseLife() {
    lives--;
    if (lives <= 0) { die(); return true; }
    return false;
  }

  void explode() {
    _state = PlayerState.exploding;
    _particles.clear();
    final rng = Random();
    for (int i = 0; i < 20; i++) {
      _particles.add([width / 2, height / 2, (rng.nextDouble() - 0.5) * 200, (rng.nextDouble() - 0.5) * 200, rng.nextDouble() * 0.4 + 0.3]);
    }
  }

  void celebrate() {
    if (_state == PlayerState.jumping || _state == PlayerState.dead || _state == PlayerState.exploding || isProjectile) return;
    _state = PlayerState.celebrating;
    _celebrationTimer = 0;
    _celebrationFrame = 0;
  }

  void goToRunning() {
    _state = PlayerState.running;
    _frameTimer = 0;
    _frameIndex = 0;
    _walkCycleTimer = 0;
    _isWalking = true;
    _jumpCount = 0;
  }

  void goToMenu() { _state = PlayerState.menu; }

  void updateMenuAnimation(double dt) {
    _menuBounceTimer += dt;
    _menuBounceOffset = sin(_menuBounceTimer * 3) * 4;
    y = RatitaGame.groundY - height + _menuBounceOffset;
  }

  void updateRunningAnimation(double dt) {
    if (_state == PlayerState.running) {
      _walkCycleTimer += dt;
      if (_isWalking) {
        _frameTimer += dt * 5;
        if (_frameTimer >= 1) { _frameTimer = 0; _frameIndex = (_frameIndex + 1) % 5; }
        if (_walkCycleTimer >= _walkCycleDuration) { _isWalking = false; _walkCycleTimer = 0; }
      } else {
        if (_walkCycleTimer >= _stopDuration) { _isWalking = true; _walkCycleTimer = 0; }
      }
    }
    if (_state == PlayerState.celebrating) {
      _celebrationTimer += dt;
      if (_celebrationTimer >= 0.3) {
        _celebrationTimer = 0;
        _celebrationFrame = (_celebrationFrame + 1) % 3;
        if (_celebrationFrame == 0) { _state = PlayerState.running; _walkCycleTimer = 0; _isWalking = true; }
      }
    }
    if (_phraseTimer > 0) { _phraseTimer -= dt; if (_phraseTimer <= 0) _currentPhrase = ''; }
  }

  void updatePhysics(double dt) {
    if (_state == PlayerState.dead) return;

    if (_state == PlayerState.exploding) {
      for (final p in _particles) { p[0] += p[2] * dt; p[1] += p[3] * dt; p[4] -= dt * 1.5; }
      _particles.removeWhere((p) => p[4] <= 0);
      return;
    }

    if (_state == PlayerState.projectileForward) {
      velocityY += 220 * dt;
      y += velocityY * dt;
      x += 200 * dt;
      if (y >= RatitaGame.groundY - height) { y = RatitaGame.groundY - height; velocityY = 0; _startInPlace(); }
      return;
    }

    if (_state == PlayerState.projectileInPlace) {
      velocityY += 250 * dt;
      y += velocityY * dt;
      if (y >= RatitaGame.groundY - height) { y = RatitaGame.groundY - height; velocityY = 0; }
      return;
    }

    if (_state == PlayerState.projectileReturn) {
      velocityY += 200 * dt;
      y += velocityY * dt;
      x += (_startX - x) * 4 * dt;
      if (y >= RatitaGame.groundY - height) {
        y = RatitaGame.groundY - height; x = _startX; velocityY = 0;
        _state = PlayerState.running; _walkCycleTimer = 0; _isWalking = true;
      }
      return;
    }

    if (_state == PlayerState.jumping) {
      velocityY += 0.65;
      y += velocityY;
      if (y >= RatitaGame.groundY - height) {
        y = RatitaGame.groundY - height; velocityY = 0;
        _state = PlayerState.running; _walkCycleTimer = 0; _isWalking = true;
        if (_jumpCount > 0 && _jumpCount % 7 == 0) _startForward();
      }
    }

    if (hasShield) { _shieldTimer += dt; if (_shieldTimer > 5) { hasShield = false; _shieldTimer = 0; } }
  }

  @override
  void render(Canvas canvas) {
    final sz = Vector2(width, height);
    final cx = width / 2;
    final cy = height / 2;

    if (hasShield) {
      canvas.drawCircle(Offset(cx, cy), width / 2 + 12, _shieldStroke);
      canvas.drawCircle(Offset(cx, cy), width / 2 + 10, _shieldFill);
    }

    if (_useSprites) {
      switch (_state) {
        case PlayerState.menu: _spriteArmOpen?.render(canvas, size: sz); break;
        case PlayerState.dead: _spriteArmCrossed?.render(canvas, size: sz); break;
        case PlayerState.exploding:
          for (final p in _particles) {
            final alpha = (p[4] * 255).clamp(0, 255).toInt();
            canvas.drawCircle(Offset(p[0].toDouble(), p[1].toDouble()), 4 + p[4] * 6,
              Paint()..color = Color.fromARGB(alpha, 255, (180 + p[4] * 75).toInt().clamp(180, 255), 0));
          }
          _spriteImpact?.render(canvas, size: sz);
          break;
        case PlayerState.celebrating:
          final sprite = _celebrationFrame == 0 ? _spriteCelebrate0 : _celebrationFrame == 1 ? _spriteCelebrate1 : _spriteCelebrate2;
          sprite?.render(canvas, size: sz);
          break;
        case PlayerState.running:
          if (!_isWalking) { _spriteFront?.render(canvas, size: sz); }
          else { [_spriteWalk0, _spriteWalk1, _spriteWalk2, _spriteWalk3, _spriteWalk4][_frameIndex]?.render(canvas, size: sz); }
          break;
        case PlayerState.jumping:
        case PlayerState.projectileForward:
        case PlayerState.projectileInPlace:
        case PlayerState.projectileReturn:
          _spriteJump?.render(canvas, size: sz);
          break;
      }
    } else {
      canvas.drawRRect(RRect.fromRectXY(Rect.fromLTWH(8, 8, width - 16, height - 16), 8, 8), Paint()..color = const Color(0xFF8B4513));
    }
  }
}
