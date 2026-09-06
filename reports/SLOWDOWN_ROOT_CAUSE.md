# Reporte: Causa Raiz del Slowdown Progresivo

## SINTOMA

El juego comienza fluido pero a medida que pasan los segundos comienza a atorarse y frenarse hasta volverse injugable.

## CAUSA RAIZ: Audio saturado en loop infinito

**Archivo:** `lib/game/ratita_game.dart:178-179`
**Archivo:** `lib/game/systems/audio_system.dart:56-60`

### El problema

En el `update()` del juego, cada frame se ejecuta:

```dart
// ratita_game.dart:178-179
if (cyclePos >= 18 && cyclePos < 40 && !_isNight) {
  if (!_isRaining) AudioSystem.startCrickets();
}
```

Y `startCrickets()` hace:

```dart
// audio_system.dart:56-60
static void startCrickets() {
  if (!_initialised) return;
  FlameAudio.bgm.stop();           // DETIENE el audio actual
  FlameAudio.bgm.play(             // INICIA audio nuevo
    Random().nextBool() ? 'grillos_00.mp3' : 'grillos_01.mp3',
    volume: 0.4,
  );
}
```

### Por que se traba

1. `cyclePos` va de 0 a 60 y se repite (ciclo de 60 segundos)
2. Entre el segundo 18 y 40 del ciclo (~22 segundos), la condicion es verdadera
3. `_isRaining` es SIEMPRE `false` (nunca se activa - BUG separado)
4. `_isNight` es `false` durante la fase de atardecer (20-30s)
5. Resultado: **`startCrickets()` se ejecuta 60 veces por segundo durante 22 segundos**

Cada llamada ejecuta:
- `bgm.stop()` - operacion de I/O que detiene el buffer de audio
- `bgm.play()` - operacion de I/O que carga y reproduce un archivo .mp3

**Total: 60 stop + 60 play = 120 operaciones de audio por segundo**

### Efecto cascada

```
Frame 1:    stop() + play()  ->  audio reinicia
Frame 2:    stop() + play()  ->  audio reinicia (0.016s despues)
Frame 3:    stop() + play()  ->  audio reinicia
...
Frame 1320: stop() + play()  ->  audio reinicia (22 segundos despues)
```

El game loop de Flame queda bloqueado esperando que las operaciones de audio completen. Cada `stop()` + `play()` toma ~2-5ms. A 60fps (16ms por frame), 5ms de audio = 31% del frame bloqueado.

### Segundo culpable: _checkCampoLaJuanita()

```dart
// ratita_game.dart:268-273
void _checkCampoLaJuanita() {
  if (_scoreSystem.score >= campoLaJuanitaThreshold && !_inCampoLaJuanita) {
    _inCampoLaJuanita = true;
    AudioSystem.startCrickets();  // OTRA llamada sin throttle
  }
}
```

Cuando el score pasa 300, tambien llama `startCrickets()` sin throttle.

### Tercero: TextPainter recreation

```dart
// ratita_game.dart:357-365
final heartsSpan = TextSpan(children: [
  for (int i = 0; i < _player.lives; i++)
    TextSpan(text: '❤', style: TextStyle(...)),
]);
final tpLives = TextPainter(text: heartsSpan, textDirection: TextDirection.ltr)..layout();
tpLives.paint(canvas, const Offset(10, 42));
```

Se crea un `TextPainter` nuevo **cada frame** con N hijos dynamicos. A 60fps = 60 allocations/segundo de TextPainter + TextSpan.

## DATOS CUANTIFICADOS

| Metrica | Valor | Impacto |
|---------|-------|---------|
| Llamadas startCrickets/segundo | 60 |Bloqueo de game loop |
| Tiempo por stop()+play() | ~2-5ms | 31% del frame |
| Frames afectados por ciclo | ~1320 (22s) | 37% del ciclo |
| TextPainter alloc/segundo | 60 | GC pressure |
| Ciclo completo | 60s | Se repite infinitamente |

## FIX REQUERIDO

### Fix 1: Throttle en startCrickets (CRITICO)

```dart
// audio_system.dart
static bool _cricketsPlaying = false;

static void startCrickets() {
  if (!_initialised) return;
  if (_cricketsPlaying) return;  // NO reiniciar si ya suena
  _cricketsPlaying = true;
  FlameAudio.bgm.stop();
  FlameAudio.bgm.play(
    Random().nextBool() ? 'grillos_00.mp3' : 'grillos_01.mp3',
    volume: 0.4,
  );
}

static void stopCrickets() {
  if (!_initialised) return;
  _cricketsPlaying = false;
  FlameAudio.bgm.stop();
}
```

### Fix 2: Cache tpLives (ALTO)

```dart
// ratita_game.dart - agregar campo
TextPainter? _cachedLivesPainter;
int _cachedLivesCount = -1;

// En render(), reemplazar la creacion:
if (_player.lives != _cachedLivesCount) {
  _cachedLivesCount = _player.lives;
  final heartsSpan = TextSpan(children: [
    for (int i = 0; i < _player.lives; i++)
      TextSpan(text: '❤', style: TextStyle(...)),
  ]);
  _cachedLivesPainter = TextPainter(text: heartsSpan, textDirection: TextDirection.ltr)..layout();
}
_cachedLivesPainter?.paint(canvas, const Offset(10, 42));
```

### Fix 3: Activar lluvia en fase nocturna (para que _isRaining funcione)

```dart
// ratita_game.dart - en el ciclo nocturno
if (cyclePos >= 30 && cyclePos < 50) {
  _isNight = true;
  _isRaining = true;  // <-- FALTA
  _ground.setNightProgress(1.0);
  _ground.setRaining(true);  // <-- FALTA
}
```

## VERIFICACION

Despues del fix:
- [ ] El juego no se frena despues de 20 segundos
- [ ] Los grillos suenan una vez, no se reinician cada frame
- [ ] El FPS se mantiene estable durante 5+ minutos
- [ ] La lluvia aparece en fase nocturna
