# Reporte de Performance y Cuellos de Botella

## PERF-001: Ground.render() recrea Paint objects frecuentemente

**Archivo:** `lib/game/components/ground.dart:102-141`

**Problema:** `_rebuildCache()` se llama cada frame en `render()`. Aunque tiene un guard `(t - _cachedT).abs() < 0.01`, cuando `_nightProgress` cambia (durante transiciones), se recrean 7 objetos `Paint` con gradientes. Esto es costoso en CPU.

**Impacto:** Stuttering durante transiciones dia/noche. En dispositivos bajos puede causar frame drops notables.

**Fix:** Precalcular todos los Paint objects posibles en `onLoad()` y solo cambiar el activo, o usar un mapa de cache mas agresivo.

---

## PERF-002: 9 nubes se renderizan cada frame con trigonometria

**Archivo:** `lib/game/components/ground.dart:189-197`

**Problema:** 9 llamadas a `_drawCloud()` cada una con `sin()` y `cos()`. Son 18 llamadas trigonometricas + 9 render calls de sprites por frame.

**Impacto:** Impacto moderado. Las nubes se mueven lento pero el overhead acumula.

**Fix:** Reducir a 4-5 nubes, o precalcular posiciones.

---

## PERF-003: 60 gotas de lluvia se actualizan y renderizan

**Archivo:** `lib/game/components/ground.dart:148-157, 223-228`

**Problema:** 60 gotas se actualizan en `update()` y 60 lineas se dibujan en `render()`. Aunque la lluvia nunca se activa (BUG-003), si se arregla, serian 120 operaciones por frame.

**Impacto:** Alto si la lluvia se activa. 120 operaciones de canvas por frame son pesadas en dispositivos bajos.

**Fix:** Reducir a 30 gotas, usar un buffer pre-renderizado, o usar un shader.

---

## PERF-004: TextPainter de vidas se recrea cada frame

**Archivo:** `lib/game/ratita_game.dart:357-365`

**Problema:** Cada frame se crea un `TextSpan` con N hijos (corazones), se hace `layout()`, y se paint. Esto allocate memoria en cada frame.

**Impacto:** GC pressure constante. En 60fps son 60 allocations/segundo solo para vidas.

**Fix:** Cache similar al de score: solo reconstruir cuando `_player.lives` cambie.

---

## PERF-005: Speech bubble TextPainter se recrea cada frame

**Archivo:** `lib/game/ratita_game.dart:392-405`

**Problema:** Cuando hay frase activa, se crea un `TextPainter` nuevo con `layout(maxWidth:)` cada frame.

**Impacto:** GC pressure cuando el jugador salta (que es frecuente).

**Fix:** Cache el TextPainter y solo reconstruir cuando `_player.currentPhrase` cambie.

---

## PERF-006: _EnemySprites carga 14 sprites en singleton

**Archivo:** `lib/game/components/enemy.dart:33-53`

**Problema:** 14 sprites se cargan en memoria y nunca se liberan. Cada sprite es una imagen completa en RAM.

**Impacto:** Uso de memoria fijo ~14 * imagen promedio. Para un juego movil es aceptable pero no ideal.

**Fix:** Lazy loading: solo cargar sprites cuando se necesitan por primera vez, o usar sprite atlas.

---

## PERF-007: Enemigos se mueven con multiplicador * 60 redundante

**Archivo:** `lib/game/components/enemy.dart:139`, `lib/game/components/friend.dart:36`

**Problema:** `x -= speed * dt * 60` - el `* 60` asume 60fps base. Esto es un patron confuso y potencialmente incorrecto.

**Impacto:** Menor, pero Contribuye a la confusion sobre calibracion de velocidad.

**Fix:** Calibrar `speed` correctamente y usar `x -= speed * dt` simple.

---

## PERF-008: Arboles se dibujan sin culling

**Archivo:** `lib/game/components/ground.dart:210-213`

**Problema:** Todos los arboles se dibujan sin importar si estan fuera de viewport. Aunque el viewport es fijo (900x500), si se cambiara, los arboles off-screen se renderizarian igual.

**Impacto:** Bajo con viewport fijo. Alto si el viewport se hace dinamico.

**Fix:** Agregar check de visibilidad antes de dibujar cada arbol.

---

## PERF-009: 60 estrellas se dibujan con trigonometria cada frame

**Archivo:** `lib/game/components/ground.dart:177-185`

**Problema:** 60 llamadas a `sin()` + 60 `drawCircle()` cada frame cuando esta oscuro.

**Impacto:** Moderado. Las estrellas son visibles ~33% del ciclo (fase nocturna).

**Fix:** Pre-calcular valores de twinkle en `onLoad()`.

---

## PERF-010: _rebuildCache recrea Gradient.linear cada transicion

**Archivo:** `lib/game/components/ground.dart:110-114`

**Problema:** Cada vez que `_nightProgress` cambia significativamente, se crea un nuevo `Gradient.linear` con 3 colores. Los gradientes son objetos de alto costo en Canvas.

**Impacto:** Durante la transicion de 10 segundos (sunset), se crean ~100 gradientes.

**Fix:** Precalcular gradientes para cada paso de 0.01 y cachear, o usar un solo gradiente con interpolacion en shader.
