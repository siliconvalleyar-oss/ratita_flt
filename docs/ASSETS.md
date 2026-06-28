# Ratita Run — Assets

## Ratita Sprites

| File | Usage |
|------|-------|
| `assets/images/ratita/ratita_run_00.png` | Run frame 0 / jump / dead |
| `assets/images/ratita/ratita_run_01.png` | Run frame 1 |
| `assets/images/ratita/ratita_run_02.png` | Run frame 2 |
| `assets/images/ratita/ratita_run_03.png` | Run frame 3 |
| `assets/images/ratita/ave.png` | Pterodactyl obstacle sprite (311x194) |

Ratita cycle: 4 frames, 10 FPS animation speed.

## Audio

| File | Usage | Duration |
|------|-------|----------|
| `assets/audio/jump.wav` | Jump sound (ascending chirp) | 150ms |
| `assets/audio/death.wav` | Death sound (descending + noise) | 500ms |
| `assets/audio/score.wav` | Score point (bright ding) | 100ms |
| `assets/audio/milestone.wav` | Every 100pts (ascending arpeggio) | 350ms |

Generated procedurally with Python (`wave` + `math` modules). Mono, 44100Hz, 16-bit PCM.

## App Icon

- Source: `assets/icon/logo.png`
- Converted to mipmap via PIL: `python3 -c "from PIL import Image; img=Image.open('logo.png'); [img.resize((s,s), Image.LANCZOS).save(f'android/app/src/main/res/mipmap-{d}/ic_launcher.png') for d,s in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]]"`

## Fallback

If sprites fail to load, all entities render via Canvas (geometric shapes). No crash.
If audio fails to load, `AudioSystem` silently skips playback. No crash.
