# Reportes de Codigo - Ratita Runner

## Indice

| Archivo | Contenido | Items |
|---------|-----------|-------|
| [BUGS_CRASHES.md](BUGS_CRASHES.md) | Bugs criticos y fallos | 10 |
| [PERFORMANCE.md](PERFORMANCE.md) | Problemas de performance | 10 |
| [DESIGN_ISSUES.md](DESIGN_ISSUES.md) | Malas implementaciones y diseno | 10 |
| [FIX_PLAN.md](FIX_PLAN.md) | Plan de correccion priorizado | 14 |

## Estadisticas

- **Bugs criticos:** 3 (score roto, fisica inconsistente, lluvia muerta)
- **Bugs altos:** 4 (audio, colisiones, memory, lifecycle)
- **Bugs medios:** 3 (state management, constants, sprites)
- **Problemas de performance:** 10
- **Problemas de diseno:** 10

## Por que se traba el juego

1. **Fisica de salto sin dt** - Causa comportamiento variable por dispositivo
2. **TextPainter recreation** - 60 allocations/segundo de GC pressure
3. **Ground paint recreation** - Gradient objects caros en transiciones
4. **Score system roto** - Recalcula score cada frame innecesariamente

## Accion inmediata

Ver `FIX_PLAN.md` para el orden de correccion priorizado. Los primeros 4 fixes toman ~55 minutos y resuelven los problemas mas criticos.
