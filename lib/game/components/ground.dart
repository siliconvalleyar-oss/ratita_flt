import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:ratita_runner/game/ratita_game.dart';

class Ground extends PositionComponent {
  double _nightProgress = 0;
  bool _isRaining = false;
  bool _showBolt = false;
  double _boltTimer = 0;
  Sprite? _cloud0;
  Sprite? _cloud1;
  Sprite? _cloud2;
  Sprite? _cloudLong;
  Sprite? _tree0;
  Sprite? _tree1;
  Sprite? _tree2;
  Sprite? _tree3;
  Sprite? _bolt0;
  Sprite? _bolt1;
  final Random _random = Random(42);
  final List<double> _starX = [];
  final List<double> _starY = [];
  final List<double> _starSize = [];
  final List<List<double>> _rainDrops = [];
  final List<double> _treeX = [];
  final List<int> _treeType = [];

  Ground()
      : super(
          size: Vector2(RatitaGame.viewportW, RatitaGame.groundY + 60),
          position: Vector2(0, 0),
        );

  @override
  Future<void> onLoad() async {
    y = 0;
    try {
      _cloud0 = await Sprite.load('ratita/nube_00.png');
      _cloud1 = await Sprite.load('ratita/nube_01.png');
      _cloud2 = await Sprite.load('ratita/nube_03.png');
      _cloudLong = await Sprite.load('ratita/nubes_larga.png');
      _tree0 = await Sprite.load('ratita/arbol_00.png');
      _tree1 = await Sprite.load('ratita/arbol_01.png');
      _tree2 = await Sprite.load('ratita/arbol_02.png');
      _tree3 = await Sprite.load('ratita/arbol_03.png');
      _bolt0 = await Sprite.load('ratita/rayo_00.png');
      _bolt1 = await Sprite.load('ratita/rayo_01.png');
    } catch (_) {}
    for (int i = 0; i < 60; i++) {
      _starX.add(_random.nextDouble() * 900);
      _starY.add(_random.nextDouble() * 200 + 20);
      _starSize.add(_random.nextDouble() * 2 + 0.5);
    }
    for (int i = 0; i < 80; i++) {
      _rainDrops.add([
        _random.nextDouble() * RatitaGame.viewportW,
        _random.nextDouble() * RatitaGame.groundY,
        _random.nextDouble() * 4 + 6,
        _random.nextDouble() * 2 + 1,
      ]);
    }
    final w = RatitaGame.viewportW;
    for (double x = 30; x < w; x += 120 + _random.nextDouble() * 60) {
      _treeX.add(x);
      _treeType.add(_random.nextInt(4));
    }
  }

  void scroll(double speed, double dt) {}

  void setNightProgress(double progress) {
    _nightProgress = progress.clamp(0.0, 1.0);
  }

  void setRaining(bool raining) {
    _isRaining = raining;
  }

  void triggerBolt() {
    _showBolt = true;
    _boltTimer = 0.15;
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
  void update(double dt) {
    super.update(dt);
    if (_boltTimer > 0) {
      _boltTimer -= dt;
      if (_boltTimer <= 0) _showBolt = false;
    }
    if (_isRaining) {
      final w = RatitaGame.viewportW;
      final groundTop = RatitaGame.groundY;
      for (final drop in _rainDrops) {
        drop[1] += drop[2] * 6;
        drop[0] -= drop[3] * 2;
        if (drop[1] > groundTop) {
          drop[1] = -drop[2];
          drop[0] = _random.nextDouble() * w;
        }
        if (drop[0] < -10) drop[0] = w + 10;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = RatitaGame.viewportW;
    final groundTop = RatitaGame.groundY;
    final t = _nightProgress;

    // sky gradient
    final topColor = _lerpColor(const Color(0xFF4A90D9), const Color(0xFF0A0A2E), t);
    final midColor = _lerpColor(const Color(0xFF87CEEB), const Color(0xFF1A1A4E), t);
    final botColor = _lerpColor(const Color(0xFFB0E0E6), const Color(0xFF2A2A5E), t);

    final skyPaint = Paint()
      ..shader = Gradient.linear(
        const Offset(0, 0),
        Offset(0, groundTop),
        [topColor, midColor, botColor],
        [0.0, 0.5, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, groundTop), skyPaint);

    // moon
    if (t > 0.3) {
      final moonAlpha = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
      final moonPaint = Paint()..color = Color.fromARGB((moonAlpha * 255).round(), 255, 255, 220);
      canvas.drawCircle(Offset(w - 120, 65), 30, moonPaint);
      canvas.drawCircle(Offset(w - 112, 60), 26, Paint()..color = _lerpColor(const Color(0xFF87CEEB), const Color(0xFF1A1A4E), t));
    }

    // stars
    if (t > 0.2) {
      final starAlpha = ((t - 0.2) / 0.8).clamp(0.0, 1.0);
      final starPaint = Paint();
      for (int i = 0; i < _starX.length; i++) {
        final twinkle = (sin(i * 1.7) + 1) * 0.5;
        starPaint.color = Color.fromARGB((starAlpha * twinkle * 255).round(), 255, 255, 200);
        canvas.drawCircle(Offset(_starX[i], _starY[i]), _starSize[i], starPaint);
      }
    }

    // clouds (static positions)
    _drawCloud(_cloud0, canvas, 50, 30, 120, 50);
    _drawCloud(_cloud1, canvas, 250, 55, 70, 35);
    _drawCloud(_cloud2, canvas, 500, 20, 100, 45);
    _drawCloud(_cloud1, canvas, 100, 80, 80, 38);
    _drawCloud(_cloudLong, canvas, 350, 100, 160, 45);
    _drawCloud(_cloud0, canvas, 650, 65, 75, 36);
    _drawCloud(_cloud2, canvas, 800, 130, 100, 45);
    _drawCloud(_cloudLong, canvas, 150, 150, 180, 50);
    _drawCloud(_cloud1, canvas, 700, 125, 70, 33);

    // lightning bolt
    if (_showBolt) {
      final bolt = _random.nextBool() ? _bolt0 : _bolt1;
      if (bolt != null) {
        bolt.render(canvas, position: Vector2(w * 0.3 + _random.nextDouble() * w * 0.4, 20), size: Vector2(80, 150));
      } else {
        final boltPaint = Paint()..color = const Color(0xFFFFFF00)..strokeWidth = 3;
        final bx = w * 0.4;
        final boltPath = Path()
          ..moveTo(bx, 30)
          ..lineTo(bx - 15, 70)
          ..lineTo(bx + 5, 65)
          ..lineTo(bx - 10, 120)
          ..lineTo(bx + 10, 80)
          ..lineTo(bx - 5, 85)
          ..lineTo(bx + 5, 30);
        canvas.drawPath(boltPath, boltPaint);
      }
    }

    // mountains (static)
    final mtnColor = _lerpColor(const Color(0xFF6B8E5A), const Color(0xFF1A3A1A), t);
    final mountainPaint = Paint()..color = mtnColor;
    for (double i = 0; i < w; i += 160) {
      final path = Path()
        ..moveTo(i, groundTop)
        ..quadraticBezierTo(i + 40, groundTop - 50 - (i * 0.1) % 20, i + 80, groundTop)
        ..quadraticBezierTo(i + 120, groundTop - 30 - (i * 0.1) % 20, i + 160, groundTop)
        ..close();
      canvas.drawPath(path, mountainPaint);
    }

    // hills (static)
    final hillColor = _lerpColor(const Color(0xFF7CAA5E), const Color(0xFF2A5A2A), t);
    final hillPaint = Paint()..color = hillColor;
    for (double i = 0; i < w; i += 120) {
      final path = Path()
        ..moveTo(i, groundTop)
        ..quadraticBezierTo(i + 30, groundTop - 25, i + 60, groundTop)
        ..quadraticBezierTo(i + 90, groundTop - 15, i + 120, groundTop)
        ..close();
      canvas.drawPath(path, hillPaint);
    }

    // trees (static)
    final trees = [_tree0, _tree1, _tree2, _tree3];
    for (int i = 0; i < _treeX.length; i++) {
      final th = 55.0 + _treeType[i] * 12;
      _drawTree(trees[_treeType[i]], canvas, _treeX[i], groundTop, th);
    }

    // ground base
    final groundColor = _lerpColor(const Color(0xFF8B7355), const Color(0xFF3A2A15), t);
    canvas.drawRect(Rect.fromLTWH(0, groundTop, w, 40), Paint()..color = groundColor);

    // ground top line
    final lineColor = _lerpColor(const Color(0xFF6B5B3E), const Color(0xFF2A1A0E), t);
    canvas.drawRect(Rect.fromLTWH(0, groundTop, w, 4), Paint()..color = lineColor);

    // grass
    final grassColor = _lerpColor(const Color(0xFF5D8A3C), const Color(0xFF1A4A1A), t);
    canvas.drawRect(Rect.fromLTWH(0, groundTop + 4, w, 3), Paint()..color = grassColor);

    // road dashes (static)
    final dashColor = _lerpColor(const Color(0xFFCCCCCC), const Color(0xFF444444), t);
    final dashPaint = Paint()..color = dashColor;
    for (double i = 0; i < w; i += 32) {
      canvas.drawRect(Rect.fromLTWH(i, groundTop + 10, 12, 3), dashPaint);
    }

    // rain
    if (_isRaining) {
      final rainPaint = Paint()..color = const Color.fromARGB(120, 180, 200, 255);
      for (final drop in _rainDrops) {
        canvas.drawLine(
          Offset(drop[0], drop[1]),
          Offset(drop[0] - drop[3] * 3, drop[1] + drop[2] * 4),
          rainPaint,
        );
      }
    }
  }
}
