import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

class Friend extends PositionComponent {
  Sprite? _sprite;
  bool _useSprites = false;
  double _floatTimer = 0;

  Friend(Random random) : super(size: Vector2(40, 50)) {
    x = RatitaGame.viewportW + 50 + random.nextDouble() * 100;
    y = RatitaGame.groundY - height - 20 - random.nextDouble() * 30;
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
    _sprite = await _load('amigo_clon_00.png');
    _useSprites = _sprite != null;
  }

  Rect get hitbox {
    return Rect.fromLTWH(x + 4, y + 4, width - 8, height - 8);
  }

  void move(double speed, double dt) {
    x -= speed * dt * 60;
    _floatTimer += dt;
    y = RatitaGame.groundY - height - 20 + sin(_floatTimer * 4) * 6;
  }

  bool get isOffScreen => x < -100;

  @override
  void render(Canvas canvas) {
    if (_useSprites && _sprite != null) {
      _sprite!.render(canvas, size: Vector2(width, height));
    } else {
      final paint = Paint()..color = const Color(0xFF00FF00);
      canvas.drawOval(Rect.fromLTWH(0, 0, width, height), paint);
      paint.color = const Color(0xFFFFFFFF);
      canvas.drawCircle(Offset(width / 2, height / 2), 6, paint);
      paint.color = const Color(0xFF00AA00);
      canvas.drawCircle(Offset(width / 2, height / 2), 3, paint);
    }
  }
}
