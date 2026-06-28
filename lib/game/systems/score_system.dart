class ScoreSystem {
  int score = 0;
  int highScore = 0;
  double speed = 6.0;
  double _distance = 0;

  void update(double dt) {
    _distance += speed * dt * 60;
    score = _distance.toInt();
    speed = (6.0 + score * 0.008).clamp(6.0, 20.0);
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
    speed = 6.0;
  }
}
