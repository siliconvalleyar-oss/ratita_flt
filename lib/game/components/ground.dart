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

  Path? _cachedMtnPath;
  Path? _cachedHillPath;
  Paint? _cachedSkyPaint;
  Paint? _cachedMtnPaint;
  Paint? _cachedHillPaint;
  Paint? _cachedGroundPaint;
  Paint? _cachedLinePaint;
  Paint? _cachedGrassPaint;
  Paint? _cachedDashPaint;
  Paint? _cachedStarPaint;
  Paint? _cachedRainPaint;
  double _cachedT = -2;

  Ground()
      : super(
          size: Vector2(RatitaGame.viewportW, RatitaGame.viewportH),
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
    for (int i = 0; i < 60; i++) {
      _rainDrops.add([
        _random.nextDouble() * RatitaGame.viewportW,
        _random.nextDouble() * RatitaGame.viewportH,
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
  void setNightProgress(double progress) { _nightProgress = progress.clamp(0.0, 1.0); }
  void setRaining(bool raining) { _isRaining = raining; }
  void triggerBolt() { _showBolt = true; _boltTimer = 0.15; }

  Color _lerpColor(Color a, Color b, double t) {
    return Color.fromARGB(255,
      (a.red + (b.red - a.red) * t).round(),
      (a.green + (b.green - a.green) * t).round(),
      (a.blue + (b.blue - a.blue) * t).round(),
    );
  }

  Color _sunsetColor(Color day, Color sunset, Color night, double t) {
    if (t < 0.5) return _lerpColor(day, sunset, t * 2);
    return _lerpColor(sunset, night, (t - 0.5) * 2);
  }

  void _rebuildCache(double t, double w, double groundTop) {
    if ((t - _cachedT).abs() < 0.01) return;
    _cachedT = t;

    final topColor = _sunsetColor(const Color(0xFF4A90D9), const Color(0xFFCC4422), const Color(0xFF0A0A2E), t);
    final midColor = _sunsetColor(const Color(0xFF87CEEB), const Color(0xFFE8733A), const Color(0xFF1A1A4E), t);
    final botColor = _sunsetColor(const Color(0xFFB0E0E6), const Color(0xFFF5A662), const Color(0xFF2A2A5E), t);

    _cachedSkyPaint = Paint()
      ..shader = Gradient.linear(
        const Offset(0, 0), Offset(0, RatitaGame.viewportH),
        [topColor, midColor, botColor], [0.0, 0.4, 1.0],
      );

    _cachedMtnPaint = Paint()..color = _lerpColor(const Color(0xFF6B8E5A), const Color(0xFF1A3A1A), t);
    _cachedHillPaint = Paint()..color = _lerpColor(const Color(0xFF7CAA5E), const Color(0xFF2A5A2A), t);
    _cachedGroundPaint = Paint()..color = _lerpColor(const Color(0xFF8B7355), const Color(0xFF3A2A15), t);
    _cachedLinePaint = Paint()..color = _lerpColor(const Color(0xFF6B5B3E), const Color(0xFF2A1A0E), t);
    _cachedGrassPaint = Paint()..color = _lerpColor(const Color(0xFF5D8A3C), const Color(0xFF1A4A1A), t);
    _cachedDashPaint = Paint()..color = _lerpColor(const Color(0xFFCCCCCC), const Color(0xFF444444), t);

    if (_cachedMtnPath == null) {
      _cachedMtnPath = Path();
      for (double i = 0; i < w; i += 160) {
        _cachedMtnPath!.moveTo(i, groundTop);
        _cachedMtnPath!.quadraticBezierTo(i + 40, groundTop - 50 - (i * 0.1) % 20, i + 80, groundTop);
        _cachedMtnPath!.quadraticBezierTo(i + 120, groundTop - 30 - (i * 0.1) % 20, i + 160, groundTop);
      }
      _cachedMtnPath!.close();
      _cachedHillPath = Path();
      for (double i = 0; i < w; i += 120) {
        _cachedHillPath!.moveTo(i, groundTop);
        _cachedHillPath!.quadraticBezierTo(i + 30, groundTop - 25, i + 60, groundTop);
        _cachedHillPath!.quadraticBezierTo(i + 90, groundTop - 15, i + 120, groundTop);
      }
      _cachedHillPath!.close();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_boltTimer > 0) { _boltTimer -= dt; if (_boltTimer <= 0) _showBolt = false; }
    if (_isRaining) {
      final w = RatitaGame.viewportW;
      final groundTop = RatitaGame.groundY;
      for (final drop in _rainDrops) {
        drop[1] += drop[2] * 6;
        drop[0] -= drop[3] * 2;
        if (drop[1] > groundTop) { drop[1] = -drop[2]; drop[0] = _random.nextDouble() * w; }
        if (drop[0] < -10) drop[0] = w + 10;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final w = RatitaGame.viewportW;
    final groundTop = RatitaGame.groundY;
    final t = _nightProgress;

    _rebuildCache(t, w, groundTop);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, RatitaGame.viewportH), _cachedSkyPaint!);

    if (t > 0.3) {
      final moonAlpha = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
      final moonPaint = Paint()..color = Color.fromARGB((moonAlpha * 255).round(), 255, 255, 220);
      canvas.drawCircle(Offset(w - 120, 65), 30, moonPaint);
      canvas.drawCircle(Offset(w - 112, 60), 26, Paint()..color = _cachedSkyPaint!.color);
    }

    if (t > 0.2) {
      final starAlpha = ((t - 0.2) / 0.8).clamp(0.0, 1.0);
      _cachedStarPaint ??= Paint();
      for (int i = 0; i < _starX.length; i++) {
        final twinkle = (sin(i * 1.7) + 1) * 0.5;
        _cachedStarPaint!.color = Color.fromARGB((starAlpha * twinkle * 255).round(), 255, 255, 200);
        canvas.drawCircle(Offset(_starX[i], _starY[i]), _starSize[i], _cachedStarPaint!);
      }
    }

    _drawCloud(_cloud0, canvas, 50, 30, 120, 50);
    _drawCloud(_cloud1, canvas, 250, 55, 70, 35);
    _drawCloud(_cloud2, canvas, 500, 20, 100, 45);
    _drawCloud(_cloud1, canvas, 100, 80, 80, 38);
    _drawCloud(_cloudLong, canvas, 350, 100, 160, 45);
    _drawCloud(_cloud0, canvas, 650, 65, 75, 36);
    _drawCloud(_cloud2, canvas, 800, 130, 100, 45);
    _drawCloud(_cloudLong, canvas, 150, 150, 180, 50);
    _drawCloud(_cloud1, canvas, 700, 125, 70, 33);

    if (_showBolt) {
      final bolt = _random.nextBool() ? _bolt0 : _bolt1;
      if (bolt != null) {
        bolt.render(canvas, position: Vector2(w * 0.3 + _random.nextDouble() * w * 0.4, 20), size: Vector2(80, 150));
      }
    }

    canvas.drawPath(_cachedMtnPath!, _cachedMtnPaint!);
    canvas.drawPath(_cachedHillPath!, _cachedHillPaint!);

    final trees = [_tree0, _tree1, _tree2, _tree3];
    for (int i = 0; i < _treeX.length; i++) {
      final th = 55.0 + _treeType[i] * 12;
      _drawTree(trees[_treeType[i]], canvas, _treeX[i], groundTop, th);
    }

    canvas.drawRect(Rect.fromLTWH(0, groundTop, w, RatitaGame.viewportH - groundTop), _cachedGroundPaint!);
    canvas.drawRect(Rect.fromLTWH(0, groundTop, w, 4), _cachedLinePaint!);
    canvas.drawRect(Rect.fromLTWH(0, groundTop + 4, w, 3), _cachedGrassPaint!);

    for (double i = 0; i < w; i += 32) {
      canvas.drawRect(Rect.fromLTWH(i, groundTop + 10, 12, 3), _cachedDashPaint!);
    }

    if (_isRaining) {
      _cachedRainPaint ??= Paint()..color = const Color.fromARGB(120, 180, 200, 255);
      for (final drop in _rainDrops) {
        canvas.drawLine(Offset(drop[0], drop[1]), Offset(drop[0] - drop[3] * 3, drop[1] + drop[2] * 4), _cachedRainPaint!);
      }
    }
  }

  void _drawCloud(Sprite? sprite, Canvas canvas, double x, double y, double w, double h) {
    if (sprite != null) {
      sprite.render(canvas, position: Vector2(x, y), size: Vector2(w, h));
    }
  }

  void _drawTree(Sprite? sprite, Canvas canvas, double x, double groundTop, double h) {
    if (sprite != null) {
      sprite.render(canvas, position: Vector2(x, groundTop - h), size: Vector2(h * 0.7, h));
    }
  }
}
