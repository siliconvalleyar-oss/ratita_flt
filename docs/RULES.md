# Reglas de Programación — Ratita Run

## Convenciones generales

- **Idioma**: Código, comentarios y nombres en **inglés**.
- **Estilo Dart**: Usar `flutter_lints`.
- **Formato**: Correr `dart format` antes de cada commit.

## Arquitectura

- **Flame para el mundo del juego**, widgets de Flutter para pantalla/pausa.
- **Systems** (`lib/game/systems/`) para lógica transversal (puntuación, audio).
- **Components** (`lib/game/components/`) para componentes del juego (player, enemy, friend, ground).
- **Screens** (`lib/game/screens/`) para widgets de Flutter (game_screen).
- **Constants** en `ratita_game.dart` (groundY, viewportW, viewportH, playerX).

## Assets

- **Sprites del Ratita**: `assets/images/ratita/ratita_caminando_derecha_00-04.png` — PNGs animación carrera.
- **Sprites de enemigos**: `assets/images/ratita/enemy_00-04.png`, `ave_*.png`, `camion_*.png`, `chancho_00.png`
- **Audio**: `assets/images/audio/` — WAV (jump, death, score, milestone) + MP3 (grillos, gallina, lluvia, relampago, chancho)
- **Icono de app**: `assets/images/icon/logo.png` — convertir a mipmap via PIL.

## Manejo de errores

- Toda inicialización asíncrona debe tener `try/catch` para evitar pantallas congeladas.
- Si falla la carga de sprites, se renderiza con Canvas como fallback.
- `AudioSystem` silencia errores si los assets no cargan.

## Commits y versionado

- Prefijos de commit: `fix:`, `feat:`, `refactor:`, `docs:`, `chore:`.
- Tags semánticos: `v1.0.0`, `v1.1.0`, etc.

## Flujo de juego

```
tap → running → (collision → loseLife → gameOver → tap → restart)
```
