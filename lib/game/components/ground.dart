import 'dart:ui';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

class Ground extends PositionComponent {
  double _scrollOffset = 0;

  Ground() : super(size: Vector2(RatitaGame.viewportW, 40));

  @override
  Future<void> onLoad() async {
    y = RatitaGame.groundY;
  }

  void scroll(double speed, double dt) {
    _scrollOffset = (_scrollOffset + speed * dt * 60) % 32;
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

    // clouds (parallax layer 1 - slow)
    final cloudPaint = Paint()..color = const Color(0xCCFFFFFF);
    for (double i = -_scrollOffset * 0.1; i < w + 100; i += 180) {
      canvas.drawOval(Rect.fromLTWH(i % (w + 200), 30 + (i * 0.3) % 80, 60, 20),
          cloudPaint);
      canvas.drawOval(
          Rect.fromLTWH(i % (w + 200) + 10, 20 + (i * 0.3) % 80, 40, 18),
          cloudPaint);
    }

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
