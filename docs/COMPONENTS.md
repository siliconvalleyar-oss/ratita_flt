# Ratita Run — Components

## Core Components

### `RatitaGame` (`lib/core/ratita_game.dart`)
- Main `FlameGame` subclass
- Manages entities, spawning, collision, rendering, game state
- Methods: `onLoad()`, `handleTap()`, `handleRelease()`, `startGame()`, `update()`, `render()`
- Game states: `_started`, `_gameOver`, `_initialised`

### `Ratita` (`lib/core/entities/ratita.dart`)
- `PositionComponent` with states: `running`, `jumping`, `dead`
- Loads `ratita_run_00-03.png` sprites (fallback to Canvas rendering)
- Physics: gravity, variable-height jump (hold timing)
- Collision box with margin (10px left/right, 8px top, 12px bottom)

### `Obstacle` (`lib/core/entities/obstacle.dart`)
- `PositionComponent` with types: `cactus`, `cactusDouble`, `pterodactyl`
- Canvas-rendered shapes (no sprites)
- Auto-removed when off-screen

### `Ground` (`lib/core/entities/ground.dart`)
- `PositionComponent` with scrolling dashed line
- Canvas-rendered

### `Cloud` (`lib/core/entities/cloud.dart`)
- `PositionComponent` with scrolling
- Canvas-rendered rounded rect + circles

### `ScoreSystem` (`lib/core/systems/score_system.dart`)
- Score, high score, speed tracking
- Speed increases progressively from 6.0 to 18.0

### `AudioSystem` (`lib/core/systems/audio_system.dart`)
- Static class wrapping `FlameAudio`
- Preloads all 4 .wav files on init
- Silent failure if audio can't load
- Methods: `jump()`, `death()`, `score()`, `milestone()`
- Milestone plays every 100 points (ascending arpeggio)
