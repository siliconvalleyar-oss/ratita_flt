import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

enum EnemyType {
  walkingChicken,
  eatingChicken,
  standingChicken,
  flyingEnemy,
  groundEnemy,
  pig
}

class Enemy extends PositionComponent {
  final EnemyType type;
  bool passed = false;
  double _animTimer = 0;
  int _animFrame = 0;

  Sprite? _spriteWalk;
  Sprite? _spriteEat0;
  Sprite? _spriteEat1;
  Sprite? _spriteEat2;
  Sprite? _spriteEat3;
  Sprite? _spriteStand;
  Sprite? _spriteFly;
  Sprite? _spriteGround;
  Sprite? _spritePig;
  bool _useSprites = false;

  Enemy({required this.type});

  factory Enemy.random(double speed, Random random) {
    final r = random.nextDouble();
    EnemyType t;
    if (r < 0.25) {
      t = EnemyType.walkingChicken;
    } else if (r < 0.40) {
      t = EnemyType.eatingChicken;
    } else if (r < 0.55) {
      t = EnemyType.standingChicken;
    } else if (r < 0.70) {
      t = EnemyType.flyingEnemy;
    } else if (r < 0.85) {
      t = EnemyType.groundEnemy;
    } else {
      t = EnemyType.pig;
    }
    return Enemy(type: t);
  }

  Future<Sprite?> _load(String filename) async {
    try {
      return await Sprite.load('assets/ratita/$filename');
    } catch (_) {
      try {
        return await Sprite.load(filename);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Future<void> onLoad() async {
    final results = await Future.wait([
      _load('ave_caminando_a_la_izquierda_00.png'),
      _load('ave_comiendo_maiz_00.png'),
      _load('ave_comiendo_maiz_01.png'),
      _load('ave_comiendo_maiz_02.png'),
      _load('ave_comiendo_maiz_03.png'),
      _load('ave_parada_a_la_izquierda_00.png'),
      _load('enemigo_01.png'),
      _load('enemigo_02.png'),
      _load('chancho_00.png'),
    ]);

    _spriteWalk = results[0];
    _spriteEat0 = results[1];
    _spriteEat1 = results[2];
    _spriteEat2 = results[3];
    _spriteEat3 = results[4];
    _spriteStand = results[5];
    _spriteFly = results[6];
    _spriteGround = results[7];
    _spritePig = results[8];

    if (_spriteWalk != null || _spriteStand != null || _spritePig != null) {
      _useSprites = true;
    }

    switch (type) {
      case EnemyType.walkingChicken:
        size.setValues(50, 50);
        y = RatitaGame.groundY - height;
        break;
      case EnemyType.eatingChicken:
        size.setValues(55, 40);
        y = RatitaGame.groundY - height;
        break;
      case EnemyType.standingChicken:
        size.setValues(50, 50);
        y = RatitaGame.groundY - height;
        break;
      case EnemyType.flyingEnemy:
        size.setValues(60, 50);
        y = RatitaGame.groundY - height - 40 - Random().nextDouble() * 30;
        break;
      case EnemyType.groundEnemy:
        size.setValues(65, 45);
        y = RatitaGame.groundY - height;
        break;
      case EnemyType.pig:
        size.setValues(55, 55);
        y = RatitaGame.groundY - height;
        break;
    }
    x = RatitaGame.viewportW + 50;
  }

  Rect get hitbox {
    return Rect.fromLTWH(x + 6, y + 6, width - 12, height - 12);
  }

  void move(double speed, double dt) {
    x -= speed * dt * 60;
  }

  bool get isOffScreen => x < -100;

  @override
  void update(double dt) {
    super.update(dt);
    _animTimer += dt;
    if (_animTimer >= 0.3) {
      _animTimer = 0;
      _animFrame = (_animFrame + 1) % 4;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_useSprites) {
      _renderSprites(canvas);
    } else {
      _renderFallback(canvas);
    }
  }

  void _renderSprites(Canvas canvas) {
    final sz = Vector2(width, height);

    switch (type) {
      case EnemyType.walkingChicken:
        _spriteWalk?.render(canvas, size: sz);
        break;
      case EnemyType.eatingChicken:
        final sprite = _animFrame == 0
            ? _spriteEat0
            : _animFrame == 1
                ? _spriteEat1
                : _animFrame == 2
                    ? _spriteEat2
                    : _spriteEat3;
        sprite?.render(canvas, size: sz);
        break;
      case EnemyType.standingChicken:
        _spriteStand?.render(canvas, size: sz);
        break;
      case EnemyType.flyingEnemy:
        _spriteFly?.render(canvas, size: sz);
        break;
      case EnemyType.groundEnemy:
        _spriteGround?.render(canvas, size: sz);
        break;
      case EnemyType.pig:
        _spritePig?.render(canvas, size: sz);
        break;
    }
  }

  void _renderFallback(Canvas canvas) {
    final paint = Paint();
    switch (type) {
      case EnemyType.walkingChicken:
        paint.color = const Color(0xFFFFA500);
        canvas.drawRRect(
            RRect.fromRectXY(Rect.fromLTWH(0, 0, width, height), 6, 6), paint);
        paint.color = const Color(0xFFFF0000);
        canvas.drawCircle(const Offset(10, 12), 4, paint);
        break;
      case EnemyType.eatingChicken:
        paint.color = const Color(0xFFFFD700);
        canvas.drawOval(Rect.fromLTWH(0, 0, width, height), paint);
        break;
      case EnemyType.standingChicken:
        paint.color = const Color(0xFFFF8C00);
        canvas.drawRRect(
            RRect.fromRectXY(Rect.fromLTWH(0, 0, width, height), 8, 8), paint);
        break;
      case EnemyType.flyingEnemy:
        paint.color = const Color(0xFF9C27B0);
        canvas.drawRRect(
            RRect.fromRectXY(Rect.fromLTWH(0, 0, width, height), 10, 10),
            paint);
        paint.color = const Color(0xFFCE93D8);
        canvas.drawRect(Rect.fromLTWH(4, 8, width - 8, 8), paint);
        break;
      case EnemyType.groundEnemy:
        paint.color = const Color(0xFF4CAF50);
        canvas.drawRRect(
            RRect.fromRectXY(Rect.fromLTWH(0, 0, width, height), 6, 6), paint);
        paint.color = const Color(0xFF2E7D32);
        canvas.drawCircle(const Offset(14, 12), 5, paint);
        break;
      case EnemyType.pig:
        paint.color = const Color(0xFFFFB6C1);
        canvas.drawRRect(
            RRect.fromRectXY(Rect.fromLTWH(0, 0, width, height), 8, 8), paint);
        paint.color = const Color(0xFFFF69B4);
        canvas.drawCircle(const Offset(12, 14), 5, paint);
        break;
    }
  }
}
