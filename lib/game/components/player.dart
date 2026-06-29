import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

enum PlayerState { menu, running, jumping, dead, celebrating }

class Player extends PositionComponent {
  PlayerState _state = PlayerState.menu;
  double velocityY = 0;
  double _frameTimer = 0;
  int _frameIndex = 0;
  bool hasShield = false;
  double _shieldTimer = 0;
  double _menuBounceTimer = 0;
  double _menuBounceOffset = 0;
  double _celebrationTimer = 0;
  int _celebrationFrame = 0;
  double _walkCycleTimer = 0;
  bool _isWalking = true;
  static const double _walkCycleDuration = 1.5;
  static const double _stopDuration = 0.6;

  Sprite? _spriteArmOpen;
  Sprite? _spriteArmCrossed;
  Sprite? _spriteRunRight0;
  Sprite? _spriteRunRight1;
  Sprite? _spriteRunRight2;
  Sprite? _spriteRunRight3;
  Sprite? _spriteRunLeft0;
  Sprite? _spriteJump;
  Sprite? _spriteFront;
  Sprite? _spriteBack;
  Sprite? _spriteCelebrate0;
  Sprite? _spriteCelebrate1;
  Sprite? _spriteCelebrate2;

  bool _useSprites = false;
  bool get hasSprites => _useSprites;

  Player() : super(size: Vector2(70, 100));

  @override
  Future<void> onLoad() async {
    final results = await Future.wait([
      _load('ratita_brazo_abierto.png'),
      _load('ratita_brazo_cruzado.png'),
      _load('ratita_caminando_derecha_00.png'),
      _load('ratita_caminando_derecha_01.png'),
      _load('ratita_caminando_derecha_02.png'),
      _load('ratita_caminando_derecha_03.png'),
      _load('ratita_caminando_a_la_izquierda.png'),
      _load('ratita_saltando.png'),
      _load('ratita_caminando_frente.png'),
      _load('ratita_espalda_00.png'),
      _load('ratita_festejando_00.png'),
      _load('ratita_festejando_01.png'),
      _load('ratita_festejando_02.png'),
    ]);

    _spriteArmOpen = results[0];
    _spriteArmCrossed = results[1];
    _spriteRunRight0 = results[2];
    _spriteRunRight1 = results[3];
    _spriteRunRight2 = results[4];
    _spriteRunRight3 = results[5];
    _spriteRunLeft0 = results[6];
    _spriteJump = results[7];
    _spriteFront = results[8];
    _spriteBack = results[9];
    _spriteCelebrate0 = results[10];
    _spriteCelebrate1 = results[11];
    _spriteCelebrate2 = results[12];

    if (_spriteJump != null || _spriteFront != null) {
      _useSprites = true;
    }

    x = RatitaGame.playerX;
    y = RatitaGame.groundY - height;
  }

  Future<Sprite?> _load(String filename) async {
    try {
      return await Sprite.load('ratita/$filename');
    } catch (e) {
      print('[RATITA] Failed to load sprite "$filename": $e');
      return null;
    }
  }

  Rect get hitbox {
    const m = 8.0;
    return Rect.fromLTWH(x + m, y + m, width - m * 2, height - m * 2);
  }

  void jump() {
    if (_state != PlayerState.running) return;
    _state = PlayerState.jumping;
    velocityY = -15;
  }

  void die() {
    _state = PlayerState.dead;
  }

  void celebrate() {
    if (_state == PlayerState.jumping || _state == PlayerState.dead) return;
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
  }

  void goToMenu() {
    _state = PlayerState.menu;
  }

  void updateMenuAnimation(double dt) {
    _menuBounceTimer += dt;
    _menuBounceOffset = sin(_menuBounceTimer * 3) * 4;
    y = RatitaGame.groundY - height + _menuBounceOffset;
  }

  void updateRunningAnimation(double dt) {
    if (_state == PlayerState.running) {
      _walkCycleTimer += dt;

      if (_isWalking) {
        _frameTimer += dt * 6;
        if (_frameTimer >= 1) {
          _frameTimer = 0;
          _frameIndex = (_frameIndex + 1) % 4;
        }
        if (_walkCycleTimer >= _walkCycleDuration) {
          _isWalking = false;
          _walkCycleTimer = 0;
        }
      } else {
        if (_walkCycleTimer >= _stopDuration) {
          _isWalking = true;
          _walkCycleTimer = 0;
        }
      }
    }
    if (_state == PlayerState.celebrating) {
      _celebrationTimer += dt;
      if (_celebrationTimer >= 0.3) {
        _celebrationTimer = 0;
        _celebrationFrame = (_celebrationFrame + 1) % 3;
        if (_celebrationFrame == 0) {
          _state = PlayerState.running;
          _walkCycleTimer = 0;
          _isWalking = true;
        }
      }
    }
  }

  void updatePhysics(double dt) {
    if (_state == PlayerState.dead) return;

    if (_state == PlayerState.jumping) {
      velocityY += 0.65;
      y += velocityY;
      if (y >= RatitaGame.groundY - height) {
        y = RatitaGame.groundY - height;
        velocityY = 0;
        _state = PlayerState.running;
        _walkCycleTimer = 0;
        _isWalking = true;
      }
    }

    if (hasShield) {
      _shieldTimer += dt;
      if (_shieldTimer > 5) {
        hasShield = false;
        _shieldTimer = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    if (_useSprites) {
      _renderSprites(canvas);
    } else {
      _renderFallback(canvas);
    }
    if (hasShield) {
      final paint = Paint()
        ..color = const Color(0x6600FF00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(
        Offset(width / 2, height / 2),
        width / 2 + 6,
        paint,
      );
    }
  }

  void _renderSprites(Canvas canvas) {
    final sz = Vector2(width, height);

    switch (_state) {
      case PlayerState.menu:
        _spriteArmOpen?.render(canvas, size: sz);
        break;

      case PlayerState.dead:
        (_spriteBack ?? _spriteArmCrossed)?.render(canvas, size: sz);
        break;

      case PlayerState.celebrating:
        final sprite = _celebrationFrame == 0
            ? _spriteCelebrate0
            : _celebrationFrame == 1
                ? _spriteCelebrate1
                : _spriteCelebrate2;
        sprite?.render(canvas, size: sz);
        break;

      case PlayerState.running:
        if (!_isWalking) {
          _spriteFront?.render(canvas, size: sz);
        } else {
          final sprite = _frameIndex == 0
              ? _spriteRunRight0
              : _frameIndex == 1
                  ? _spriteRunRight1
                  : _frameIndex == 2
                      ? _spriteRunRight2
                      : _spriteRunRight3;
          if (sprite != null) {
            sprite.render(canvas, size: sz);
          } else {
            (_spriteFront ?? _spriteRunLeft0)?.render(canvas, size: sz);
          }
        }
        break;

      case PlayerState.jumping:
        _spriteJump?.render(canvas, size: sz);
        break;
    }
  }

  void _renderFallback(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFF8B4513);
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(8, 8, width - 16, height - 16), 8, 8),
      paint,
    );
    paint.color = const Color(0xFFA0522D);
    canvas.drawCircle(Offset(width - 16, 20), 6, paint);
    paint.color = const Color(0xFF222222);
    canvas.drawCircle(Offset(width - 14, 18), 2, paint);
  }
}
