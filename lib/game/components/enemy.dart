import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

enum EnemyType {
  walkingChicken,
  eatingChicken,
  standingChicken,
  enemy0,
  enemy1,
  enemy2,
  pig,
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
  Sprite? _spriteEnemy0;
  Sprite? _spriteEnemy1;
  Sprite? _spriteEnemy2;
  Sprite? _spritePig;
  bool _useSprites = false;

  Enemy({required this.type});

  factory Enemy.random(double speed, Random random) {
    final r = random.nextDouble();
    EnemyType t;
    if (r < 0.20) {
      t = EnemyType.walkingChicken;
    } else if (r < 0.35) {
      t = EnemyType.eatingChicken;
    } else if (r < 0.45) {
      t = EnemyType.standingChicken;
    } else if (r < 0.60) {
      t = EnemyType.enemy0;
    } else if (r < 0.75) {
      t = EnemyType.enemy1;
    } else if (r < 0.88) {
      t = EnemyType.enemy2;
    } else {
      t = EnemyType.pig;
    }
    return Enemy(type: t);
  }

  Future<Sprite?> _load(String filename) async {
    try {
      return await Sprite.load('ratita/$filename');
    } catch (_) {
      return null;
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
      _load('enemy_00.png'),
      _load('enemy_01.png'),
      _load('enemy_02.png'),
      _load('chancho_00.png'),
    ]);

    _spriteWalk = results[0];
    _spriteEat0 = results[1];
    _spriteEat1 = results[2];
    _spriteEat2 = results[3];
    _spriteEat3 = results[4];
    _spriteStand = results[5];
    _spriteEnemy0 = results[6];
    _spriteEnemy1 = results[7];
    _spriteEnemy2 = results[8];
    _spritePig = results[9];

    if (_spriteWalk != null || _spriteStand != null || _spritePig != null ||
        _spriteEnemy0 != null || _spriteEnemy1 != null || _spriteEnemy2 != null) {
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
      case EnemyType.enemy0:
        size.setValues(55, 52);
        y = RatitaGame.groundY - height;
        break;
      case EnemyType.enemy1:
        size.setValues(52, 54);
        y = RatitaGame.groundY - height;
        break;
      case EnemyType.enemy2:
        size.setValues(56, 56);
        y = RatitaGame.groundY - height;
        break;
      case EnemyType.pig:
        size.setValues(55, 40);
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
      case EnemyType.enemy0:
        _spriteEnemy0?.render(canvas, size: sz);
        break;
      case EnemyType.enemy1:
        _spriteEnemy1?.render(canvas, size: sz);
        break;
      case EnemyType.enemy2:
        _spriteEnemy2?.render(canvas, size: sz);
        break;
      case EnemyType.pig:
        _spritePig?.render(canvas, size: sz);
        break;
    }
  }

  void _renderFallback(Canvas canvas) {
    final paint = Paint();
    paint.color = const Color(0xFFFF4444);
    canvas.drawRRect(
      RRect.fromRectXY(Rect.fromLTWH(0, 0, width, height), 6, 6), paint);
  }
}
