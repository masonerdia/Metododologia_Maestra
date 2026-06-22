---
tipo: bug
titulo: "inicio >= NOW()" encuentra eventos futuros, no todos los de hoy — distinción crítica para marcar asistencia
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** En el asistente de voz se necesitaban dos queries distintas sobre citas:
- `proximaCita()` — la PRÓXIMA cita no cancelada (para reagendar, confirmar, cancelar).
- `citaHoy()` — la cita del DÍA DE HOY activa (para marcar asistencia — el paciente ya llegó).

La query de `proximaCita` usaba `c.inicio >= NOW()` con ORDER BY inicio LIMIT 1. Esto es correcto para encontrar citas futuras, pero falla para `citaHoy`: si la cita era a las 10:00 y son las 14:00, `inicio >= NOW()` ya no la encuentra — la cita "pasó" aunque sea del mismo día.

**Causa raíz / por qué importa:** `NOW()` compara a nivel de TIMESTAMP exacto. Una cita de hoy cuya hora ya pasó tiene `inicio < NOW()` → no aparece en el resultado. Para marcar asistencia, el hecho relevante es el CALENDARIO, no si el timestamp todavía está en el futuro.

**Cómo aplicarlo / evitarlo:**

Distinguir explícitamente los dos patrones en SQL con PostgreSQL:

```sql
-- PATRÓN A: próxima cita futura (reagendar, cancelar, confirmar)
WHERE c.inicio >= NOW()
  AND c.estado <> 'cancelada'
ORDER BY c.inicio LIMIT 1

-- PATRÓN B: cita activa de hoy (marcar asistencia, corte del día, recordatorios)
WHERE (c.inicio AT TIME ZONE 'America/Mexico_City')::date = '2026-06-22'  -- hoyISO
  AND c.estado IN ('agendada', 'confirmada')
ORDER BY c.inicio LIMIT 1
```

Regla: si la acción depende del CALENDARIO del día (¿vino hoy?), usar patrón B.
Si depende de "lo que viene" (¿cuándo es su próxima cita?), usar patrón A.

**¿Específico de un stack?** No. El problema es conceptual (confundir "timestamp en el futuro" con "del día de hoy") y aparece en cualquier SQL con columnas `timestamptz`. La solución con `AT TIME ZONE tz)::date` es específica de PostgreSQL pero el patrón de distinción es universal.
