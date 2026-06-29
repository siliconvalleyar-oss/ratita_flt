class ScoreSystem {
  int score = 0;
  int highScore = 0;
  double speed = 4.0;
  double _distance = 0;

  void update(double dt) {
    _distance += speed * dt * 60;
    score = _distance.toInt();
    speed = (4.0 + score * 0.005).clamp(4.0, 14.0);
  }

  bool checkHighScore() {
    if (score > highScore) {
      highScore = score;
      return true;
    }
    return false;
  }

  void reset() {
    score = 0;
    _distance = 0;
    speed = 4.0;
  }
}
