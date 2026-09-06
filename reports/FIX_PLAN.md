# Plan de Correccion - Prioridad y Acciones

## RESUMEN EJECUTIVO

El juego "Ratita Runner" tiene **10 bugs criticos**, **10 problemas de performance**, y **10 malas implementaciones**. Los bugs mas impactantes causan:

1. **Score roto** - bonuses por enemigos se pierden cada frame
2. **Fisica inconsistente** - salto depende del framerate del dispositivo
3. **Features muertas** - lluvia, truenos y grillos nunca se activan correctamente
4. **Memory pressure** - TextPainters se recrean cada frame

---

## PRIORIDAD 1 - CRITICO (Arreglar primero)

### P1-1: Fix score accumulation (BUG-001)
- **Archivo:** `lib/game/systems/score_system.dart`
- **Accion:** Agregar campo `_bonus` para acumular puntos de enemigos
- **Esfuerzo:** 15 min
- **Impacto:** Arregla el sistema de scoring completo

### P1-2: Fix frame-dependent jump physics (BUG-002)
- **Archivo:** `lib/game/components/player.dart:251-258`
- **Accion:** Multiplicar por `dt` en `updatePhysics()`
- **Esfuerzo:** 10 min
- **Impacto:** Salto consistente en todos los dispositivos

### P1-3: Fix rain/thunder never activating (BUG-003 + BUG-007)
- **Archivo:** `lib/game/ratita_game.dart:160-175`
- **Accion:** Setear `_isRaining = true` y `_ground.setRaining(true)` en fase nocturna
- **Esfuerzo:** 10 min
- **Impacto:** Activa features completas del juego (lluvia, truenos, sonidos)

### P1-4: Fix cricket audio conflicts (BUG-004)
- **Archivo:** `lib/game/ratita_game.dart:178-182, 268-273`
- **Accion:** Unificar logica de grillos con Campo La Juanita
- **Esfuerzo:** 20 min
- **Impacto:** Audio consistente

---

## PRIORIDAD 2 - ALTO (Mejora significativa)

### P2-1: Fix TextPainter memory allocation (BUG-005, PERF-004, PERF-005)
- **Archivo:** `lib/game/ratita_game.dart:357-405`
- **Accion:** Cachear `tpLives` y speech bubble, solo reconstruir en cambio de estado
- **Esfuerzo:** 30 min
- **Impacto:** Reduce GC pressure significativamente

### P2-2: Fix collision only detects one enemy (BUG-006)
- **Archivo:** `lib/game/ratita_game.dart:284-316`
- **Accion:** Continuar iteracion despues de primera colision
- **Esfuerzo:** 15 min
- **Impacto:** Colisiones correctas

### P2-3: Fix AudioSystem lifecycle (BUG-008)
- **Archivo:** `lib/game/systems/audio_system.dart:54,62`
- **Accion:** Agregar check `_initialised` en stopRain/stopCrickets
- **Esfuerzo:** 5 min
- **Impacto:** Previene crashes

### P2-4: Optimize Ground rendering (PERF-001, PERF-002, PERF-009)
- **Archivo:** `lib/game/components/ground.dart`
- **Accion:** Precalcular paints, reducir nubes a 5, cachear twinkle de estrellas
- **Esfuerzo:** 45 min
- **Impacto:** Mejora FPS en dispositivos bajos

---

## PRIORIDAD 3 - MEDIO (Clean code y mantenibilidad)

### P3-1: Centralizar constants (DESIGN-009)
- **Accion:** Crear `lib/game/config.dart` con todas las constantes
- **Esfuerzo:** 30 min

### P3-2: Fix removeAll() state management (BUG-009)
- **Archivo:** `lib/game/ratita_game.dart:89-97`
- **Accion:** Resetear componentes en vez de recrear
- **Esfuerzo:** 45 min

### P3-3: Fix enemy speed multiplier (BUG-010, PERF-007)
- **Archivo:** `lib/game/components/enemy.dart:139`, `lib/game/components/friend.dart:36`
- **Accion:** Verificar calibracion y simplificar
- **Esfuerzo:** 15 min

### P3-4: Fix sprite fallback visibility (DESIGN-010)
- **Archivo:** Todos los componentes
- **Accion:** No activar hitbox si sprite fallo, o mostrar placeholder visible
- **Esfuerzo:** 30 min

---

## PRIORIDAD 4 - BAJO (Refactor a futuro)

### P4-1: Separate RatitaGame responsibilities (DESIGN-004)
- **Esfuerzo:** 2-3 horas
- **Nota:** Refactor grande, hacer despues de estabilizar

### P4-2: Use Flame components properly (DESIGN-005)
- **Esfuerzo:** 2-3 horas
- **Nota:** Migrar a SpriteAnimationComponent, Hitbox, etc.

### P4-3: Make AudioSystem injectable (DESIGN-003)
- **Esfuerzo:** 1-2 horas
- **Nota:** Para testing y lifecycle

---

## ARCHIVOS A MODIFICAR (en orden)

1. `lib/game/systems/score_system.dart` - fix score accumulation
2. `lib/game/components/player.dart` - fix jump physics
3. `lib/game/ratita_game.dart` - fix rain/crickets/collisions
4. `lib/game/components/ground.dart` - optimize rendering
5. `lib/game/systems/audio_system.dart` - fix lifecycle

---

## TESTING

Despues de cada fix, verificar:
- [ ] Score acumula correctamente (BUG-001)
- [ ] Salto es igual a 30fps y 60fps (BUG-002)
- [ ] Lluvia aparece en fase nocturna (BUG-003)
- [ ] Truenos suenan durante lluvia (BUG-003)
- [ ] Grillos no se cortan en Campo La Juanita (BUG-004)
- [ ] FPS estable en dispositivo bajo (PERF-*)
- [ ] No hay crashes al reiniciar juego (BUG-009)
