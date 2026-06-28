# Ratita Run — Sound System

## Architecture

Sounds are managed by `AudioSystem` (`lib/core/systems/audio_system.dart`), a static wrapper around `FlameAudio`.

### Initialization

```dart
await AudioSystem.init();  // called once in main.dart
```

Preloads all 4 WAV files into the audio cache. If loading fails, all play methods silently no-op.

## Sound Effects

| Trigger | Method | File | Duration | Description |
|---------|--------|------|----------|-------------|
| Jump | `AudioSystem.jump()` | `jump.wav` | 150ms | Rising chirp (400→1200Hz) |
| Death | `AudioSystem.death()` | `death.wav` | 500ms | Descending tone (600→100Hz) + noise |
| Score | `AudioSystem.score()` | `score.wav` | 100ms | Bright ding (880+1320Hz) |
| Milestone | `AudioSystem.milestone()` | `milestone.wav` | 350ms | Arpeggio (C5-E5-G5-C6) |

### Volume Levels

| Sound | Volume |
|-------|--------|
| Jump | 0.5 |
| Death | 0.6 |
| Score | 0.3 |
| Milestone | 0.5 |

## Generation

All WAV files are generated procedurally with Python 3 (standard library only: `wave`, `struct`, `math`, `random`).

Format: Mono, 44100 Hz, 16-bit PCM.

To regenerate:
```bash
python3 << 'EOF'
# See scripts/gen_sounds.py or inline generation logic
EOF
```

## Integration Points

| File | Line | Event |
|------|------|-------|
| `ratita_game.dart` | `handleTap()` | Jump sound on tap |
| `ratita_game.dart` | `_checkCollisions()` | Death sound on collision |
| `ratita_game.dart` | `update()` | Score sound per obstacle passed |
| `ratita_game.dart` | `update()` | Milestone sound at each 100pt threshold |
| `main.dart` | `main()` | Preload all sounds at startup |

## Dependencies

- `flame_audio: ^2.1.0` (wraps `audioplayers`)
- Assets under `assets/audio/` registered in `pubspec.yaml`
