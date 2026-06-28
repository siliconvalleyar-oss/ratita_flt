# Behabior — Project Prompt

## Overview

Professional 2D top-down pixel defender built with **Flutter 3.2+** & **Flame Engine 1.17+** for Android.
Wave-based combat, Rive-animated sprites, 6 skills, 8 achievements, boss battles with multi-phase AI.

**Theme:** Dark neon-purple (#6C5CE7), glass-morphism UI.

---

## Architecture

Layered: **Data** → **Game (Flame)** → **UI (Flutter Widgets)**

### Data Layer (`lib/data/`)
- **Models**: Pure data classes (LevelModel, EnemyModel, SkillModel, AchievementModel, WaveModel)
- **Repositories**: SharedPreferences persistence (SaveRepository, LevelRepository, AchievementRepository)
- **Providers**: `GameState` (ChangeNotifier) global state via Provider

### Game Layer (`lib/core/`)
- `CoreGame` → FlameGame subclass, orchestrates all systems
- **Engine**: SpawnEngine (wave spawning), CollisionSystem (circle overlap, layer filtering)
- **Entities**: BaseEntity (HP, position, state machine), Player, Enemy, Boss, Projectile
- **Components**: JoystickComponent, RiveSpriteComponent, ParticleComponent, CameraShakeEffect, DamageFlashComponent, ScreenTransition, HealthBarComponent
- **Effects**: LiquidEffectComponent (fluid splash), GlassEffectComponent (shatter shards), FluidSquadEffectComponent (blob physics)
- **Systems**: AudioSystem, ScoreSystem, WaveSystem, AchievementSystem, SkillSystem

### UI Layer (`lib/ui/`)
- **Screens**: MenuScreen, GameScreen (GameWidget + HUD overlay), LevelSelectScreen, SettingsScreen, AchievementsScreen, ShopScreen
- **Widgets**: HUD, PauseMenu, GameOverOverlay, WaveIndicator
- **Theme**: AppTheme (dark neon colors)

---

## Game Mechanics

### Player
- 8-directional movement via virtual joystick (bottom-left)
- Tap attack button (bottom-right) → shoot projectile in movement direction
- Cooldown-based firing (300ms default)
- Invincibility frames (1s after hit)
- Speed: 200px/s base + skill bonuses
- Size: 32x32

### Enemies (6 types)
| Type | HP | Speed | Behavior |
|------|----|-------|----------|
| Grunt | 30 | 80 | Chase + melee |
| Runner | 15 | 160 | Fast, low HP |
| Brute | 120 | 40 | Slow, high damage |
| Sniper | 20 | 50 | Ranged |
| Medic | 25 | 70 | Heals nearby |
| Bomber | 10 | 90 | Explodes on death |

### Boss
- Multi-phase AI (HP thresholds: 60%, 30%)
- Attacks: shockwave (AoE), spread_shot (5 bullets), laser_beam, meteor_storm
- Phase changes trigger visual effects

### Waves
- 3-8 waves per level
- Random edge spawn, boss every 3-5 waves
- Score bonus per wave + time bonus

### Collision System
- Circle-based overlap detection
- Layers: player, enemy, projectile, boss
- Matrix: player↔enemy (damage), projectile↔enemy (hit), projectile↔boss (hit)

---

## Skills (6 total)

| Skill | Type | Base/Level | Max | Cost |
|-------|------|------------|-----|------|
| Vitality (health_boost) | Passive | +100 HP / +25 | 5 | 1pt |
| Swift (speed_boost) | Passive | +30 spd / +15 | 5 | 1pt |
| Power (damage_boost) | Passive | +5 dmg / +5 | 5 | 1pt |
| Barrier (shield) | Active | 2s shield / +1s | 3 | 2pt |
| Berserker (rage) | Active | 1.5x atk spd / +0.5x | 3 | 2pt |
| Nova Blast (nova) | Ultimate | 50 AoE / +25 | 3 | 3pt |

**Prerequisites:** Barrier→Vitality Lv2, Berserker→Power Lv2, Nova→Barrier+1 & Berserker+1

---

## Achievements (8)
Kills: 100/500/1000. Waves: 25/100. Bosses: 10. Skill: all maxed. Secret.

---

## Assets

### Rive (.riv) — state machine: "State Machine" with inputs: speed(0-1), direction(0-360), attack(trigger), hit(trigger), death(trigger)
- `player.riv`, `enemy_basic.riv`, `enemy_fast.riv`, `enemy_tank.riv`, `enemy_ranged.riv`, `enemy_healer.riv`, `enemy_explosive.riv`, `boss.riv`, `projectile.riv`

### Audio
- Music: `theme.mp3`, `battle.mp3`, `boss.mp3`
- SFX: 12 .wav files (shoot, hit, explosion, enemy_death, player_hit, level_up, achievement, button_click, glass_break, wave_start, boss_warning, pickup)

### Images (legacy fallback PNG)
- `images/naves/nave_00.png` — player ship
- `images/naves/enemy_00.png` through `enemy_02.png` — enemies
- `images/backgrounds/level_1.png` through `level_5.png`

---

## Key Implementation Details

### Flame Setup
- `FlameGame` with `CameraComponent.withFixedResolution(800, 600)`
- World coordinate system: 1600x1200
- Entities added to `world` (not game root) so camera renders them
- `camera.follow(player)` for auto-follow
- `camera.viewfinder.anchor = Anchor.center`
- Background via `camera.backgroundColor` or backdrop component

### Game Loop (per frame)
1. Camera shake decay
2. Score system (combo timer)
3. Player physics + health bar update
4. Enemy AI (target → move → attack)
5. Boss AI (phase check → attack pattern)
6. Projectile movement + cleanup
7. Remove dead entities
8. Collision detection
9. Spawn engine (wave logic)
10. Check game over / level complete

### State Machine (BaseEntity)
- States: idle, moving, attacking, damaged, dying, dead
- `onStateChanged()` hook for Rive animation triggers

### Projectile Pooling
- Reuse Projectile instances (object pool pattern)
- Active/inactive flag, positioned off-screen when inactive

### Audio
- Wrap `FlameAudio.audioCache.loadAll()` in try/catch
- Independent music/SFX volume
- BGM pooling with crossfade

### Save Format (SharedPreferences)
```json
{
  "skills": { "health_boost": 2, ... },
  "levels": { "1": { "stars": 3, "completed": true } },
  "achievements": { "first_kill": true, ... },
  "settings": { "musicVolume": 0.5, "sfxVolume": 0.7 }
}
```

---

## What to Build

Generate a complete Flutter + Flame game project with:
1. Clean layer separation (data/core/ui)
2. All 6 skill types working with prerequisites
3. Wave-based combat with 6 enemy types
4. Boss with 4-phase AI
5. Rive animation support (graceful fallback to shapes if .riv missing)
6. Achievement system
7. Camera with fixed resolution + player follow
8. All visual effects (particles, shake, flash, transitions, fluid/glass)
9. Joystick + tap attack controls
10. HUD with score, health, wave, combo
11. Level select with star rating
12. Settings (audio sliders)
13. Shop (skill tree UI)
14. Save/load progress
