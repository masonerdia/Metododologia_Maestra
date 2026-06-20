---
tipo: bug
titulo: to_char() / funciones en columna de filtro impiden el uso del índice — usar bounds UTC
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Un filtro de citas del día usaba `to_char(c.inicio AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD') = $hoy`. Aunque se creó un índice sobre `citas(clinica_id, paciente_id, inicio)`, el planner no lo podía usar: el índice indexa el valor crudo de `inicio`, pero la condición aplica una función sobre la columna antes de comparar — el planner no puede invertir esa transformación.

**Causa raíz / por qué importa:** Cualquier función sobre la columna indexada en el WHERE (`to_char`, `date_trunc`, `AT TIME ZONE`, `LOWER`, `EXTRACT`, etc.) convierte el predicado en "no sargable" — el planner debe evaluar la función para cada fila antes de comparar, forzando un seq scan. El índice queda inútil aunque apunte exactamente a esa columna.

**Cómo aplicarlo / evitarlo:**
- **Bounds en la columna cruda:** en lugar de `to_char(inicio) = $dia`, usar: `inicio >= $dia_inicio_utc AND inicio < $dia_siguiente_utc`. El planner puede usarlo directamente como range scan sobre el índice B-tree.
- Para Postgres con `timestamptz` y zona horaria: `inicio >= ($dia::date)::timestamp AT TIME ZONE 'America/Mexico_City'` — convierte la constante (no la columna) a UTC.
- Para índices de expresión: si el filtro con función es inevitable, crear un índice funcional sobre la misma expresión: `CREATE INDEX ON citas (to_char(inicio AT TIME ZONE 'America/Mexico_City', 'YYYY-MM-DD'))`. El índice se usará si la condición es idéntica.
- Regla general: **mover la función al lado de la constante, no al lado de la columna**.

**¿Específico de un stack?** No. Aplica a cualquier base de datos relacional con índices B-tree. La forma exacta de "bound UTC" es específica de Postgres con `timestamptz`, pero el principio (no aplicar funciones a la columna indexada) es universal.
