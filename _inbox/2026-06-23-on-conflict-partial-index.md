---
tipo: bug
titulo: "ON CONFLICT con índice parcial requiere WHERE explícito en la cláusula"
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** En DENTI-0048 se creó un índice UNIQUE parcial en PostgreSQL con condición `WHERE recurrente_origen_id IS NOT NULL` para garantizar idempotencia en la materialización de gastos recurrentes. La primera versión del INSERT usaba `ON CONFLICT (clinica_id, recurrente_origen_id, fecha) DO NOTHING` sin cláusula WHERE. PostgreSQL rechazó la operación en runtime con: `there is no unique or exclusion constraint matching the ON CONFLICT specification`.

**Causa raíz / por qué importa:** Un índice UNIQUE parcial no es equivalente a un índice UNIQUE completo desde la perspectiva del planificador de conflictos de PostgreSQL. Para que el motor lo reconozca como el constraint objetivo, la cláusula `ON CONFLICT` debe incluir la misma condición `WHERE` que la definición del índice. Sin ella, PostgreSQL no puede determinar de forma determinista cuál constraint usar, y rechaza la query. El error solo aparece en runtime (no en `tsc`, no en el parser SQL), y si los datos de prueba no incluyen el caso de duplicado, los tests pasan igualmente.

**Cómo aplicarlo / evitarlo:**

```sql
-- Definición del índice
CREATE UNIQUE INDEX idx_tabla_idempotente
  ON tabla(col_a, col_b, col_c)
  WHERE col_b IS NOT NULL;

-- ON CONFLICT DEBE replicar la cláusula WHERE:
INSERT INTO tabla (...)
VALUES (...)
ON CONFLICT (col_a, col_b, col_c)
  WHERE col_b IS NOT NULL   -- <-- obligatorio
DO NOTHING;
```

Regla: al escribir un `ON CONFLICT` que apunta a un índice parcial, copiar exactamente la cláusula `WHERE` del índice en la cláusula `ON CONFLICT`. Incluir un test que verifique que el segundo INSERT devuelve 0 filas (no lanzar excepción = no basta).

**¿Específico de un stack?** Sí — PostgreSQL (confirmado en 15 y 16). MySQL/SQLite no tienen esta sintaxis. Va a adaptador PostgreSQL si existe, o a 00-Principios si el principio se generaliza como "el motor solo usa el constraint que puede identificar de forma única".
