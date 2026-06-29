import 'dart:ui';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

class Ground extends PositionComponent {
  double _scrollOffset = 0;
  Sprite? _cloud0;
  Sprite? _cloud1;
  Sprite? _cloud2;
  Sprite? _cloudLong;

  Ground() : super(size: Vector2(RatitaGame.viewportW, 40));

  @override
  Future<void> onLoad() async {
    y = RatitaGame.groundY;
    try {
      _cloud0 = await Sprite.load('ratita/nube_00.png');
      _cloud1 = await Sprite.load('ratita/nube_01.png');
      _cloud2 = await Sprite.load('ratita/nube_02.png');
      _cloudLong = await Sprite.load('ratita/nubes_larga.png');
    } catch (_) {}
  }

  void scroll(double speed, double dt) {
    _scrollOffset = (_scrollOffset + speed * dt * 60) % 32;
  }

  void _drawCloud(Sprite? sprite, Canvas canvas, double x, double y, double w, double h) {
    if (sprite != null) {
      sprite.render(canvas, position: Vector2(x, y), size: Vector2(w, h));
    } else {
      final cloudPaint = Paint()..color = const Color(0xCCFFFFFF);
      canvas.drawOval(Rect.fromLTWH(x, y, w * 0.8, h * 0.5), cloudPaint);
      canvas.drawOval(Rect.fromLTWH(x + w * 0.15, y - h * 0.15, w * 0.5, h * 0.4), cloudPaint);
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;

    // sky gradient
    final skyPaint = Paint()
      ..shader = Gradient.linear(
        const Offset(0, -300),
        const Offset(0, 100),
        [
          const Color(0xFF4A90D9),
          const Color(0xFF87CEEB),
          const Color(0xFFB0E0E6)
        ],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, -300, w, 600), skyPaint);

    // clouds - row 1 (far, slow)
    _drawCloud(_cloud0, canvas, (-_scrollOffset * 0.05) % (w + 200) - 50, 40, 90, 40);
    _drawCloud(_cloud1, canvas, (-_scrollOffset * 0.05 + 250) % (w + 200) - 50, 60, 70, 35);
    _drawCloud(_cloud2, canvas, (-_scrollOffset * 0.05 + 500) % (w + 200) - 50, 30, 110, 50);

    // clouds - row 2 (mid, medium speed)
    _drawCloud(_cloud1, canvas, (-_scrollOffset * 0.12) % (w + 200) - 50, 90, 80, 38);
    _drawCloud(_cloudLong, canvas, (-_scrollOffset * 0.12 + 300) % (w + 200) - 80, 110, 160, 45);
    _drawCloud(_cloud0, canvas, (-_scrollOffset * 0.12 + 600) % (w + 200) - 50, 75, 75, 36);

    // clouds - row 3 (near, faster)
    _drawCloud(_cloud2, canvas, (-_scrollOffset * 0.2) % (w + 200) - 60, 140, 100, 45);
    _drawCloud(_cloudLong, canvas, (-_scrollOffset * 0.2 + 350) % (w + 200) - 80, 160, 180, 50);
    _drawCloud(_cloud1, canvas, (-_scrollOffset * 0.2 + 700) % (w + 200) - 50, 135, 70, 33);

    // mountains (parallax layer 2 - medium)
    final mountainPaint = Paint()..color = const Color(0xFF6B8E5A);
    for (double i = -_scrollOffset * 0.3; i < w; i += 160) {
      final path = Path()
        ..moveTo(i, 0)
        ..quadraticBezierTo(i + 40, -50 - (i * 0.1) % 20, i + 80, 0)
        ..quadraticBezierTo(i + 120, -30 - (i * 0.1) % 20, i + 160, 0)
        ..close();
      canvas.drawPath(path, mountainPaint);
    }

    // hills (parallax layer 3 - faster)
    final hillPaint = Paint()..color = const Color(0xFF7CAA5E);
    for (double i = -_scrollOffset * 0.5; i < w; i += 120) {
      final path = Path()
        ..moveTo(i, 0)
        ..quadraticBezierTo(i + 30, -25, i + 60, 0)
        ..quadraticBezierTo(i + 90, -15, i + 120, 0)
        ..close();
      canvas.drawPath(path, hillPaint);
    }

    // ground base
    final groundPaint = Paint()..color = const Color(0xFF8B7355);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 40), groundPaint);

    // ground top line
    final linePaint = Paint()..color = const Color(0xFF6B5B3E);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 4), linePaint);

    // grass detail on top
    final grassPaint = Paint()..color = const Color(0xFF5D8A3C);
    canvas.drawRect(Rect.fromLTWH(0, 4, size.x, 3), grassPaint);

    // road dashes (moving)
    final dashPaint = Paint()..color = const Color(0xFFCCCCCC);
    for (double i = -_scrollOffset; i < size.x; i += 32) {
      canvas.drawRect(Rect.fromLTWH(i, 10, 12, 3), dashPaint);
    }
  }
}
