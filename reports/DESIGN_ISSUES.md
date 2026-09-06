# Reporte de Malas Implementaciones y Diseno

## DESIGN-001: Frame-rate dependent physics en Player

**Archivo:** `lib/game/components/player.dart:251-258`

**Problema:** El salto no usa `dt` para fisicas:
```dart
velocityY += 0.65;  // NO usa dt
y += velocityY;      // NO usa dt
```
Mientras que las其它 fisicas SI usan dt (projectileForward, etc).

**Impacto:** Inconsistencia grave. El juego se comporta diferente en cada dispositivo.

**Regla:** TODA la fisica debe usar `dt` para ser frame-rate independent.

---

## DESIGN-002: ScoreSystem tiene doble fuente de verdad

**Archivo:** `lib/game/systems/score_system.dart:8-10` + `lib/game/ratita_game.dart:259`

**Problema:** El score viene de dos fuentes:
1. `_distance` (automatico por tiempo)
2. `score += 10` (bonus por enemigos)

Pero `_scoreSystem.update()` sobreescribe `score = _distance.toInt()`, perdiendo los bonuses.

**Impacto:** Sistema de score roto. Los bonuses nunca persisten.

**Regla:** Un score debe tener UNA sola fuente de verdad. Usar acumuladores separados.

---

## DESIGN-003: AudioSystem es 100% estatico sin lifecycle

**Archivo:** `lib/game/systems/audio_system.dart`

**Problema:** Todo es `static`. No hay forma de:
- Pausar/resumir audio correctamente
- Manejar multiples instancias
- Testear (no se puede mockear)
- Limpiar recursos

**Impacto:** Dificultad para testing, memory leaks potenciales, audio glitchy en transiciones.

**Regla:** Los sistemas deberian ser instancias inyectables con lifecycle claro.

---

## DESIGN-004: RatitaGame tiene demasiadas responsabilidades

**Archivo:** `lib/game/ratita_game.dart`

**Problema:** La clase RatitaGame maneja:
- Estado del juego (menu, playing, gameOver)
- Spawning de enemigos y amigos
- Colisiones
- Fisicas del ciclo dia/noche
- Audio
- Renderizado de UI (score, vidas, frases)
- Logica de milestones
- Campo La Juanita

**Impacto:** Clase de 409 lineas dificil de mantener, testear y debugear.

**Regla:** Separar en: GameState, SpawnManager, CollisionSystem, DayNightCycle, UIRenderer.

---

## DESIGN-005: Enemy y Friend no usan componentes Flame correctamente

**Archivo:** `lib/game/components/enemy.dart:56-196`, `lib/game/components/friend.dart:6-56`

**Problema:** Ambos clases extienden `PositionComponent` pero:
- No usan `SpriteAnimationComponent` para animaciones
- Manejan movimiento manualmente en vez de usar `MoveEffect`
- No usan `Hitbox` de Flame para colisiones
- Render manual en vez de usar el sistema de sprites de Flame

**Impacto:** Codigo mas largo, mas propenso a bugs, no aprovecha optimizaciones de Flame.

---

## DESIGN-006: _EnemySprites singleton es problematico

**Archivo:** `lib/game/components/enemy.dart:20-54`

**Problema:** Singleton con `_loaded` flag:
- Si `loadAll()` falla parcialmente, `_loaded = true` pero algunos sprites son null
- No hay forma de recargar si los assets cambian
- Acopla TODOS los sprites de enemigos en un solo lugar

**Impacto:** Sprites parcialmente cargados causan rendering invisible (enemigos que no se ven pero causan colision).

**Fix:** Cargar sprites por tipo de enemigo, o manejar fallos individualmente.

---

## DESIGN-007: Managment de vida del jugador es fragil

**Archivo:** `lib/game/ratita_game.dart:200-211`

**Problema:** `_explodeTimer` maneja la Explosion -> loseLife -> gameOver en el update loop. Si el timer se desincroniza con el estado del player, puede haber doble dano o dano perdido.

**Impacto:** Posible doble-resta de vida o vidas que no se pierden.

**Regla:** Usar un estado machine explícito en vez de timers ad-hoc.

---

## DESIGN-008: No hay separation of concerns en render()

**Archivo:** `lib/game/ratita_game.dart:318-408`

**Problema:** `render()` de RatitaGame dibuja:
- Flash overlay de trueno
- Score text
- High score text
- Vidas (corazones)
- Campo La Juanita label
- Speech bubble con frase

Todo en un solo metodo de 90 lineas con logica condicional compleja.

**Impacto:** Dificil de mantener, el render order es fragile, los TextPainters se gestionan inline.

---

## DESIGN-009: Hardcoded constants por todas partes

**Archivos:** Multiples

**Problema:** Valores magicos dispersos:
- `groundY = 340` (ratita_game.dart:44)
- `viewportW = 900`, `viewportH = 500` (ratita_game.dart:45-46)
- `playerX = 100` (ratita_game.dart:47)
- `velocityY = -16` (player.dart:131)
- `0.65` gravity (player.dart:252)
- `60` multiplier (enemy.dart:139, friend.dart:36)
- `150` ms audio throttle (audio_system.dart:34)

**Impacto:** Dificil de sintonizar el juego. Cambiar un valor puede romper otros.

**Fix:** Centralizar en un `GameConfig` class o `GameConstants`.

---

## DESIGN-010: No hay manejo de errores en carga de assets

**Archivos:** Todos los archivos de componentes

**Problema:** Los `_load()` catchean errores y retornan null:
```dart
Future<Sprite?> _load(String filename) async {
  try { return await Sprite.load('ratita/$filename'); } catch (_) { return null; }
}
```
Los sprites null causan rendering invisible pero los hitboxes siguen activos.

**Impacto:** Enemigos invisibles que causan dano. Player invisible pero colisiona.

**Fix:** Si un sprite falla, no agregar el componente al juego, o usar fallback visual claro.
