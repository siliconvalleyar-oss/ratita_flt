# Reglas de Programación — Ratita Run

## Convenciones generales

- **Idioma**: Código, comentarios y nombres en **inglés**.
- **Estilo Dart**: Usar `flutter_lints`.
- **Formato**: Correr `dart format` antes de cada commit.

## Arquitectura

- **Flame para el mundo del juego**, widgets de Flutter para pantalla/pausa.
- **Systems** (`lib/core/systems/`) para lógica transversal (puntuación).
- **Entities** (`lib/core/entities/`) para componentes del juego (ratita, obstáculos, suelo, nubes).
- **Config** (`lib/core/config/`) para constantes de juego.

## Assets

- **Sprites del Ratita**: `assets/images/ratita/ratita_run_00-03.png` — PNGs animación carrera.
- **Icono de app**: `assets/icon/logo.png` — convertir a mipmap manualmente via PIL/ImageMagick.

## Manejo de errores

- Toda inicialización asíncrona debe tener `try/catch` para evitar pantallas congeladas.
- Si falla la carga de sprites, se renderiza con Canvas como fallback.

## Commits y versionado

- Prefijos de commit: `fix:`, `feat:`, `refactor:`, `docs:`, `chore:`.
- Tags semánticos: `v1.0.0`, `v1.1.0`, etc.

## Regla de monitoreo

- Cada 5 minutos leer `chat.txt` y verificar si hay tareas pendientes.

## Flujo de juego

```
tap → running → (collision → gameOver → tap → restart)
```
