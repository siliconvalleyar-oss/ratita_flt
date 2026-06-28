# Dino Run — Systems

## ScoreSystem (`lib/core/systems/score_system.dart`)

- `score` — current score, increments by 10 per obstacle passed
- `highScore` — best score (session only)
- `speed` — current scroll speed, increases with score

### Speed Progression

- Start: `6.0`
- Max: `18.0`
- Formula: `6.0 + score * 0.005`

### Methods

- `update(dt)` — increment distance-based score
- `reset()` — reset score and speed
- `checkHighScore()` — update high score if current is higher

## AudioSystem (`lib/core/systems/audio_system.dart`)

Static wrapper around `FlameAudio`. Preloads all WAV files at startup.

### Sounds

| Sound | File | Trigger |
|-------|------|---------|
| Jump | `jump.wav` | Dino jumps |
| Death | `death.wav` | Collision |
| Score | `score.wav` | Obstacle passed |
| Milestone | `milestone.wav` | Every 100 points |

### Initialization

```dart
await AudioSystem.init();  // main.dart
```

Methods silently no-op if init failed or audio assets missing.
