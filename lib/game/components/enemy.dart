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

class _EnemySprites {
  Sprite? walk;
  Sprite? eat0, eat1, eat2, eat3;
  Sprite? stand;
  Sprite? enemy0, enemy1, enemy2;
  Sprite? pig;
  static bool _loaded = false;

  static final _EnemySprites instance = _EnemySprites._();

  _EnemySprites._();

  static Future<void> loadAll() async {
    if (_loaded) return;
    _loaded = true;
    final i = instance;
    try {
      i.walk = await Sprite.load('ratita/ave_caminando_a_la_izquierda_00.png');
      i.eat0 = await Sprite.load('ratita/ave_comiendo_maiz_00.png');
      i.eat1 = await Sprite.load('ratita/ave_comiendo_maiz_01.png');
      i.eat2 = await Sprite.load('ratita/ave_comiendo_maiz_02.png');
      i.eat3 = await Sprite.load('ratita/ave_comiendo_maiz_03.png');
      i.stand = await Sprite.load('ratita/ave_parada_a_la_izquierda_00.png');
      i.enemy0 = await Sprite.load('ratita/enemy_00.png');
      i.enemy1 = await Sprite.load('ratita/enemy_01.png');
      i.enemy2 = await Sprite.load('ratita/enemy_02.png');
      i.pig = await Sprite.load('ratita/chancho_00.png');
    } catch (_) {}
  }
}

class Enemy extends PositionComponent {
  final EnemyType type;
  bool passed = false;
  double _animTimer = 0;
  int _animFrame = 0;

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

  @override
  Future<void> onLoad() async {
    await _EnemySprites.loadAll();

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
    final s = _EnemySprites.instance;
    final sz = Vector2(width, height);

    switch (type) {
      case EnemyType.walkingChicken:
        s.walk?.render(canvas, size: sz);
        break;
      case EnemyType.eatingChicken:
        final sprite = _animFrame == 0 ? s.eat0 : _animFrame == 1 ? s.eat1 : _animFrame == 2 ? s.eat2 : s.eat3;
        sprite?.render(canvas, size: sz);
        break;
      case EnemyType.standingChicken:
        s.stand?.render(canvas, size: sz);
        break;
      case EnemyType.enemy0:
        s.enemy0?.render(canvas, size: sz);
        break;
      case EnemyType.enemy1:
        s.enemy1?.render(canvas, size: sz);
        break;
      case EnemyType.enemy2:
        s.enemy2?.render(canvas, size: sz);
        break;
      case EnemyType.pig:
        s.pig?.render(canvas, size: sz);
        break;
    }
  }
}
