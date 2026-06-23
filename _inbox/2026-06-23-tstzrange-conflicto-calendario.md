---
tipo: patron
titulo: tstzrange overlap para detección de conflictos de calendario en PostgreSQL
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: Adaptadores/PostgreSQL
---

**Qué pasó / contexto:** Para detectar si una cita nueva se solapa con citas existentes, la solución intuitiva es comparar manualmente inicio/fin con AND/OR. La solución correcta en PostgreSQL es usar el operador de solapamiento de rangos.

**Causa raíz / por qué importa:** La comparación manual de intervalos es verbosa y propensa a errores en los bordes (intervalos abiertos vs cerrados). PostgreSQL tiene un tipo `tstzrange` (timestamp with timezone range) con operadores nativos, incluyendo `&&` (overlap) que maneja correctamente los bordes y puede ser indexado eficientemente con GiST.

**Cómo aplicarlo / evitarlo:**
```sql
-- Detectar solapamiento entre [inicio_nuevo, fin_nuevo) y citas existentes
SELECT c.id, p.nombre, t.nombre
FROM citas c
JOIN pacientes p ON p.id = c.paciente_id
JOIN tratamientos t ON t.id = c.tratamiento_id
WHERE c.deleted_at IS NULL
  AND c.estado NOT IN ('cancelada', 'no_asistio', 'reagendada')
  AND tstzrange(c.inicio, c.fin, '[)') && tstzrange($1::timestamptz, $2::timestamptz, '[)')
LIMIT 1;
```
- `[)` = cerrado por la izquierda, abierto por la derecha. Una cita de 10:00–11:00 no conflicta con una de 11:00–12:00.
- Para índice GiST: `CREATE INDEX ON citas USING GIST (tstzrange(inicio, fin, '[)')) WHERE deleted_at IS NULL;`
- Para excluir IDs (ej. la cita que se está editando): `AND NOT (c.id = ANY($3::uuid[]))`
- Para proyectar bloqueos recurrentes al día objetivo: `(fecha_objetivo::date + (b.inicio AT TIME ZONE 'tz')::time) AT TIME ZONE 'tz'`

**¿Específico de un stack?** Sí — PostgreSQL. MySQL/SQLite no tienen tipos de rango nativos (requieren comparación manual: `inicio < $fin AND fin > $inicio`).
