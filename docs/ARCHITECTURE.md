# Ratita Run — Architecture

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp
├── core/
│   ├── ratita_game.dart           # Main FlameGame (update, render, collision, spawn)
│   ├── config/
│   │   └── game_config.dart     # Constants (gravity, speed, sizes)
│   ├── entities/
│   │   ├── ratita.dart            # Player (jump, run animation, die)
│   │   ├── obstacle.dart        # Cactus & pterodactyl obstacles
│   │   ├── ground.dart          # Scrolling ground line
│   │   └── cloud.dart           # Decorative scrolling clouds
│   └── systems/
│       ├── score_system.dart    # Score, speed, high score
│       └── audio_system.dart    # Sound effects (jump, death, score, milestone)
└── ui/
    ├── screens/
    │   └── game_screen.dart     # Flutter wrapper with Listener
    └── themes/
        └── app_theme.dart       # Minimal theme
```

## Data Flow

```
Listener (touch) → RatitaGame.handleTap() → Ratita.jump() + AudioSystem.jump()
Game loop (dt)   → update() → physics, spawn, collision, scoring, audio
render()         → Canvas → text, sprites, ground, obstacles, clouds
```
## Audio Flow

```
AudioSystem.init()  → preloads all .wav files
RatitaGame.handleTap()      → AudioSystem.jump()
RatitaGame._checkCollisions → AudioSystem.death()
RatitaGame.update (obstacle) → AudioSystem.score() / AudioSystem.milestone()
```
