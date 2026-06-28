# Changelog

## [1.1.0] — 2026-06-23

### Added
- Sound effects: jump, death, score, milestone (every 100 points)
- Audio system with `flame_audio` (jump.wav, death.wav, score.wav, milestone.wav)
- Pterodactyl sprite (`ave.png`) for the flying obstacle
- Improved jump physics (higher jump, floatier arc)
- Smaller collision hitboxes for fairer gameplay

### Changed
- Updated ratita sprites with adjusted frames
- ARCHITECTURE.md, ASSETS.md, COMPONENTS.md, API.md updated for audio
- README.md expanded with all doc links

### Fixed
- Collision detection now accounts for visual-only areas
- Ratita sprite sizes adapt to actual PNG dimensions

## [1.0.0] — Initial Release

- Basic Chrome Ratita clone
- Cacti and pterodactyl obstacles (canvas-rendered)
- Score system with progressive speed
- Ratita sprites (4-frame run animation)
- Ground, clouds, game states (start/gameover/restart)
