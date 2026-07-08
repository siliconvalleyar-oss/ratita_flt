class ScoreSystem {
  int score = 0;
  int highScore = 0;
  double speed = 3.0;
  double _distance = 0;
  double _bonus = 0;

  void addBonus(int points) {
    _bonus += points;
  }

  void update(double dt) {
    _distance += speed * dt * 60;
    score = (_distance + _bonus).toInt();
    speed = (3.0 + score * 0.004).clamp(3.0, 12.0);
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
    _bonus = 0;
    speed = 3.0;
  }
}
