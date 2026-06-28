# Ratita Run — API

## Public Interface

### `RatitaGame`

```dart
class RatitaGame extends FlameGame {
  bool get gameStarted;
  bool get gameOver;
  ScoreSystem get scoreSystem;

  void handleTap();
  void handleRelease();
  void startGame();
}
```

### `Ratita`

```dart
class Ratita extends PositionComponent {
  RatitaState ratitaState; // running, jumping, dead
  double velocityY;

  void jump();
  void releaseJump();
  void die();
  void updatePhysics(double dt);
}
```

### `Obstacle`

```dart
class Obstacle extends PositionComponent {
  ObstacleType type;    // cactus, cactusDouble, pterodactyl
  bool passed;
  bool get isOffScreen;

  void move(double speed, double dt);
  factory Obstacle.random(double speed);
}
```

### `ScoreSystem`

```dart
class ScoreSystem {
  int score;
  int highScore;
  double speed;

  void update(double dt);
  void reset();
  void checkHighScore();
}
```

### `AudioSystem`

```dart
class AudioSystem {
  static Future<void> init();  // Preload all sounds
  static void jump();          // Play jump sound
  static void death();         // Play death sound
  static void score();         // Play score point sound
  static void milestone();     // Play milestone sound (every 100pts)
}
```
