# Reporte de Bugs y Fallos Criticos

## BUG-001: Score de enemigos se pierde cada frame (CRITICO)

**Archivo:** `lib/game/ratita_game.dart:256-263` + `lib/game/systems/score_system.dart:8-9`

**Problema:** `_scoreSystem.update(dt)` asigna `score = _distance.toInt()` cada frame. Luego, el bonus de +10 por pasar un enemigo se suma al score. En el siguiente frame, `update()` sobreescribe el score con `_distance.toInt()`, perdiendo TODOS los bonuses acumulados.

**Impacto:** El jugador nunca acumula puntos por esquivar enemigos. Solo gana puntos por distancia recorrida. El juego se siente injusto y el score no refleja la habilidad real.

**Fix:** Accumular el bonus en una variable separada o incluirlo en `_distance`:
```dart
// score_system.dart - agregar campo
double _bonus = 0;

void addBonus(int points) { _bonus += points; }

void update(double dt) {
  _distance += speed * dt * 60;
  score = (_distance + _bonus).toInt();
  speed = (3.0 + score * 0.004).clamp(3.0, 12.0);
}

void reset() { score = 0; _distance = 0; _bonus = 0; speed = 3.0; }
```

---

## BUG-002: Fisica de salto dependiente de framerate (CRITICO)

**Archivo:** `lib/game/components/player.dart:251-258`

**Problema:** El salto usa `velocityY += 0.65` y `y += velocityY` SIN multiplicar por `dt`. A 60fps la gravedad es 39/s, a 30fps es 19.5/s. El salto es inconsistente entre dispositivos.

**Impacto:** En dispositivos lentos el salt es mas bajo, en dispositivos rapidos es mas alto. Puede causar que el jugador no pueda saltar obstaculos en ciertos dispositivos.

**Fix:**
```dart
if (_state == PlayerState.jumping) {
  velocityY += 650 * dt;  // gravedad consistente
  y += velocityY * dt;
  // ...
}
```

---

## BUG-003: Lluvia y trueno NUNCA se activan (CRITICO)

**Archivo:** `lib/game/ratita_game.dart:27,86,164-175`

**Problema:** `_isRaining` se inicializa en `false` y NUNCA se pone en `true`. El ciclo nocturno (30-50s) solo setea `_isNight = true` pero no `_isRaining = true`. Las condiciones `_isRaining` en lineas 185-193 y en `Ground` nunca se ejecutan.

**Impacto:** No hay lluvia visual, no hay truenos, no hay sonidos de lluvia. Una feature completa del juego esta muerta.

**Fix:** Agregar en el ciclo nocturno:
```dart
if (cyclePos >= 30 && cyclePos < 50) {
  _isNight = true;
  _isRaining = true;  // <-- FALTA
  _ground.setNightProgress(1.0);
  _ground.setRaining(true);  // <-- FALTA
} else {
  _isRaining = false;
  _ground.setRaining(false);
}
```

---

## BUG-004: Grillos se detienen prematuramente

**Archivo:** `lib/game/ratita_game.dart:178-182`

**Problema:** `AudioSystem.stopCrickets()` se ejecuta cuando `cyclePos >= 40`, pero `_checkCampoLaJuanita()` (linea 269-273) inicia grillos cuando score >= 300 sin importar el ciclo. Si el jugador esta en Campo La Juanita y el ciclo llega a 40, los grillos se detienen aunque el score sea > 300.

**Impacto:** Audio inconsistente. Los grillos de Campo La Juanita se cortan cada ciclo de 60 segundos.

**Fix:** No detener grillos si estamos en Campo La Juanita, o unificar la logica de audio.

---

## BUG-005: TextPainter se crea cada frame (MEMORIA)

**Archivo:** `lib/game/ratita_game.dart:357-365`

**Problema:** En `render()`, el `TextPainter` de corazones (`tpLives`) se crea y layout cada frame con un nuevo `TextSpan` dinamico. Lo mismo para el speech bubble (linea 392-405).

**Impacto:** Presion de GC constante, posible stuttering/frame drops en dispositivos bajos.

**Fix:** Cachear el `tpLives` y solo reconstruir cuando `_player.lives` cambie, similar a como se hace con `_tpScore`.

---

## BUG-006: Collisions solo detecta un enemigo por frame

**Archivo:** `lib/game/ratita_game.dart:284-316`

**Problema:** `_checkCollisions()` hace `return` despues de la primera colision detectada. Si dos enemigos tocan al jugador simultaneamente, solo uno se procesa.

**Impacto:** El jugador puede "atravesar" un segundo enemigo si ambos colisionan en el mismo frame.

**Fix:** No hacer `return` despues de cada colision, continuar iterando (con flag para evitar doble dano):
```dart
void _checkCollisions() {
  bool hit = false;
  // ... enemies loop
  if (playerBox.overlaps(e.hitbox) && !hit) {
    hit = true;
    // handle collision
  }
  // ... friends loop
}
```

---

## BUG-007: _isRaining nunca setea Ground.setRaining()

**Archivo:** `lib/game/ratita_game.dart` vs `lib/game/components/ground.dart:86`

**Problema:** Incluso si `_isRaining` se activara en `RatitaGame`, nunca se llama `_ground.setRaining(true)`. Ground nunca sabe que esta lloviendo, por lo que no renderiza gotas de lluvia.

**Impacto:** La lluvia visual nunca aparece.

**Fix:** En el ciclo nocturno, llamar `_ground.setRaining(_isRaining)`.

---

## BUG-008: AudioSystem.stopRain() y stopCrickets() sin check de inicializacion

**Archivo:** `lib/game/systems/audio_system.dart:54,62`

**Problema:** `stopRain()` y `stopCrickets()` llaman `FlameAudio.bgm.stop()` sin verificar `_initialised`. Si se llaman antes de `init()`, pueden crashear.

**Impacto:** Crash potencial al inicio de la app o en reinicios rapidos.

**Fix:**
```dart
static void stopRain() { if (!_initialised) return; FlameAudio.bgm.stop(); }
static void stopCrickets() { if (!_initialised) return; FlameAudio.bgm.stop(); }
```

---

## BUG-009: removeAll() + recrear componentes puede causar estado inconsistente

**Archivo:** `lib/game/ratita_game.dart:89-97, 112-118`

**Problema:** `startGame()` y `goToMenu()` llaman `removeAll(children)` que elimina TODOS los componentes, incluyendo los que estan en proceso de `onLoad()`. Luego crean nuevos `Player` y `Ground`. Si un componente antiguo termina su `onLoad()` despues de ser removido, puede intentar agregarse a un game tree invalido.

**Impacto:** Posible crash o comportamiento indefinido en reinicios rapidos.

**Fix:** Usar `removeAll()` con cuidado, o melhor: solo remover enemies/friends y resetear player/ground en vez de recrear todo.

---

## BUG-010: Enemy.move() usa multiplicador fijo * 60

**Archivo:** `lib/game/components/enemy.dart:139`

**Problema:** `x -= speed * dt * 60` asume 60fps como base. Aunque `dt` compensa, el `* 60` es redundante y confuso. Si `speed` ya representa unidades/segundo, el `* 60` es incorrecto.

**Impacto:** Velocidad de enemigos inconsistente si `speed` no esta calibrada para 60fps.

**Fix:** Verificar la calibracion de `speed` en `ScoreSystem` y remover el `* 60` si no es necesario, o ajustar `speed` base.
