import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

class Ground extends PositionComponent {
  double _scrollOffset = 0;
  double _nightProgress = 0;
  Sprite? _cloud0;
  Sprite? _cloud1;
  Sprite? _cloud2;
  Sprite? _cloudLong;
  Sprite? _tree0;
  Sprite? _tree1;
  Sprite? _tree2;
  Sprite? _tree3;
  final Random _random = Random(42);
  final List<double> _starX = [];
  final List<double> _starY = [];
  final List<double> _starSize = [];

  Ground() : super(size: Vector2(RatitaGame.viewportW, 40));

  @override
  Future<void> onLoad() async {
    y = RatitaGame.groundY;
    try {
      _cloud0 = await Sprite.load('ratita/nube_00.png');
      _cloud1 = await Sprite.load('ratita/nube_01.png');
      _cloud2 = await Sprite.load('ratita/nube_03.png');
      _cloudLong = await Sprite.load('ratita/nubes_larga.png');
      _tree0 = await Sprite.load('ratita/arbol_00.png');
      _tree1 = await Sprite.load('ratita/arbol_01.png');
      _tree2 = await Sprite.load('ratita/arbol_02.png');
      _tree3 = await Sprite.load('ratita/arbol_03.png');
    } catch (_) {}
    for (int i = 0; i < 60; i++) {
      _starX.add(_random.nextDouble() * 900);
      _starY.add(_random.nextDouble() * 200 - 280);
      _starSize.add(_random.nextDouble() * 2 + 0.5);
    }
  }

  void scroll(double speed, double dt) {
    _scrollOffset = (_scrollOffset + speed * dt * 60) % 32;
  }

  void setNightProgress(double progress) {
    _nightProgress = progress.clamp(0.0, 1.0);
  }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.fromARGB(
      255,
      (a.red + (b.red - a.red) * t).round(),
      (a.green + (b.green - a.green) * t).round(),
      (a.blue + (b.blue - a.blue) * t).round(),
    );
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

  void _drawTree(Sprite? sprite, Canvas canvas, double x, double groundTop, double h) {
    if (sprite != null) {
      sprite.render(canvas, position: Vector2(x, groundTop - h), size: Vector2(h * 0.7, h));
    } else {
      final trunkPaint = Paint()..color = const Color(0xFF8B4513);
      canvas.drawRect(Rect.fromLTWH(x + h * 0.25, groundTop - h * 0.4, h * 0.15, h * 0.4), trunkPaint);
      final leafPaint = Paint()..color = const Color(0xFF228B22);
      canvas.drawOval(Rect.fromLTWH(x, groundTop - h, h * 0.65, h * 0.6), leafPaint);
    }
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final t = _nightProgress;

    // sky gradient (day to night)
    final topColor = _lerpColor(const Color(0xFF4A90D9), const Color(0xFF0A0A2E), t);
    final midColor = _lerpColor(const Color(0xFF87CEEB), const Color(0xFF1A1A4E), t);
    final botColor = _lerpColor(const Color(0xFFB0E0E6), const Color(0xFF2A2A5E), t);

    final skyPaint = Paint()
      ..shader = Gradient.linear(
        const Offset(0, -300),
        const Offset(0, 100),
        [topColor, midColor, botColor],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, -300, w, 600), skyPaint);

    // stars (visible at night)
    if (t > 0.2) {
      final starAlpha = ((t - 0.2) / 0.8).clamp(0.0, 1.0);
      final starPaint = Paint()..color = Color.fromARGB((starAlpha * 255).round(), 255, 255, 255);
      for (int i = 0; i < _starX.length; i++) {
        final sx = (_starX[i] - _scrollOffset * 0.02) % w;
        final twinkle = (sin(_scrollOffset * 0.05 + i * 1.7) + 1) * 0.5;
        starPaint.color = Color.fromARGB((starAlpha * twinkle * 255).round(), 255, 255, 200);
        canvas.drawCircle(Offset(sx < 0 ? sx + w : sx, _starY[i]), _starSize[i], starPaint);
      }
    }

    // clouds - slow single cloud
    _drawCloud(_cloud0, canvas, (-_scrollOffset * 0.03) % (w + 200) - 50, 50, 120, 50);

    // clouds - row 1 (far)
    _drawCloud(_cloud1, canvas, (-_scrollOffset * 0.05 + 250) % (w + 200) - 50, 70, 70, 35);
    _drawCloud(_cloud2, canvas, (-_scrollOffset * 0.05 + 500) % (w + 200) - 50, 35, 100, 45);

    // clouds - row 2 (mid)
    _drawCloud(_cloud1, canvas, (-_scrollOffset * 0.12) % (w + 200) - 50, 95, 80, 38);
    _drawCloud(_cloudLong, canvas, (-_scrollOffset * 0.12 + 300) % (w + 200) - 80, 115, 160, 45);
    _drawCloud(_cloud0, canvas, (-_scrollOffset * 0.12 + 600) % (w + 200) - 50, 80, 75, 36);

    // clouds - row 3 (near)
    _drawCloud(_cloud2, canvas, (-_scrollOffset * 0.2) % (w + 200) - 60, 145, 100, 45);
    _drawCloud(_cloudLong, canvas, (-_scrollOffset * 0.2 + 350) % (w + 200) - 80, 165, 180, 50);
    _drawCloud(_cloud1, canvas, (-_scrollOffset * 0.2 + 700) % (w + 200) - 50, 140, 70, 33);

    // mountains
    final mtnColor = _lerpColor(const Color(0xFF6B8E5A), const Color(0xFF1A3A1A), t);
    final mountainPaint = Paint()..color = mtnColor;
    for (double i = -_scrollOffset * 0.3; i < w; i += 160) {
      final path = Path()
        ..moveTo(i, 0)
        ..quadraticBezierTo(i + 40, -50 - (i * 0.1) % 20, i + 80, 0)
        ..quadraticBezierTo(i + 120, -30 - (i * 0.1) % 20, i + 160, 0)
        ..close();
      canvas.drawPath(path, mountainPaint);
    }

    // hills
    final hillColor = _lerpColor(const Color(0xFF7CAA5E), const Color(0xFF2A5A2A), t);
    final hillPaint = Paint()..color = hillColor;
    for (double i = -_scrollOffset * 0.5; i < w; i += 120) {
      final path = Path()
        ..moveTo(i, 0)
        ..quadraticBezierTo(i + 30, -25, i + 60, 0)
        ..quadraticBezierTo(i + 90, -15, i + 120, 0)
        ..close();
      canvas.drawPath(path, hillPaint);
    }

    // trees (parallax layer - behind ground)
    final trees = [_tree0, _tree1, _tree2, _tree3];
    for (double i = -_scrollOffset * 0.6; i < w + 80; i += 130) {
      final treeIdx = ((i ~/ 130).abs() % 4).toInt();
      _drawTree(trees[treeIdx], canvas, i % (w + 160) - 40, 0, 60 + (treeIdx * 10).toDouble());
    }

    // ground base
    final groundColor = _lerpColor(const Color(0xFF8B7355), const Color(0xFF3A2A15), t);
    final groundPaint = Paint()..color = groundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 40), groundPaint);

    // ground top line
    final lineColor = _lerpColor(const Color(0xFF6B5B3E), const Color(0xFF2A1A0E), t);
    final linePaint = Paint()..color = lineColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, 4), linePaint);

    // grass detail on top
    final grassColor = _lerpColor(const Color(0xFF5D8A3C), const Color(0xFF1A4A1A), t);
    final grassPaint = Paint()..color = grassColor;
    canvas.drawRect(Rect.fromLTWH(0, 4, size.x, 3), grassPaint);

    // road dashes
    final dashColor = _lerpColor(const Color(0xFFCCCCCC), const Color(0xFF444444), t);
    final dashPaint = Paint()..color = dashColor;
    for (double i = -_scrollOffset; i < size.x; i += 32) {
      canvas.drawRect(Rect.fromLTWH(i, 10, 12, 3), dashPaint);
    }
  }
}
