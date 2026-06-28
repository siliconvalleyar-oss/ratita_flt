# Ratita Run

Chrome Ratita-style endless runner built with **Flutter** & **Flame Engine** for Android.

**Repo:** https://github.com/siliconvalleyar-oss/behabior

## Gameplay

- Tap to jump, hold for higher jump
- Avoid cacti and pterodactyls (with sprite `ave.png`)
- Progressive speed as score increases
- Sound effects: jump, death, score, milestone (every 100pts)
- Game over on collision, tap to restart
- High score tracked via ScoreSystem

## Tech Stack

| Technology | Purpose |
|------------|---------|
| Flutter 3.2+ | Cross-platform UI |
| Flame 1.17+ | Game engine, components, game loop |
| flame_audio 2.1+ | Sound effect playback |

## Quick Start

```bash

cd behabior
flutter pub get
flutter run
```

## Build APK

```bash
flutter build apk --release
```

## Documentation

- [GAME.md](docs/GAME.md) — Game description
- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — Architecture
- [GAME_DESIGN.md](docs/GAME_DESIGN.md) — Game design
- [COMPONENTS.md](docs/COMPONENTS.md) — Components
- [ASSETS.md](docs/ASSETS.md) — Assets
- [SOUNDS.md](docs/SOUNDS.md) — Audio system
- [SYSTEMS.md](docs/SYSTEMS.md) — Score & audio systems
- [API.md](docs/API.md) — Public API reference
- [DEPLOY.md](docs/DEPLOY.md) — Build & install
- [CHANGELOG.md](CHANGELOG.md) — Version history
- [TODO.md](TODO.md) — Tasks
