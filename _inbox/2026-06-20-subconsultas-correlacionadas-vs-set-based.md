---
tipo: patron
titulo: Subconsultas correlacionadas en SELECT son O(N×M) — reemplazar con aggregate JOINs + LATERAL
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** La página de listado de pacientes tardaba varios segundos con 911 filas. La query principal tenía 4 subconsultas en el SELECT (saldo cargos, saldo abonos, cita hoy, próxima cita), cada una con `WHERE ca.paciente_id = p.id`. Con 911 pacientes el planner ejecutaba cada subconsulta una vez por fila: O(911 × 4) scans de las tablas de cargos, abonos y citas.

**Causa raíz / por qué importa:** Las subconsultas correlacionadas en el SELECT son cómodas de escribir pero el planner las evalúa una vez por fila del outer query. Con tablas grandes (cargos, abonos, citas crecen indefinidamente) esto es O(N×M) — el mismo motivo por el que se evitan N+1 queries en ORM. No hay índice que compense completamente ese patrón.

**Cómo aplicarlo / evitarlo:**
- **Aggregate JOINs** para columnas de agregación (saldo = cargos - abonos): `LEFT JOIN (SELECT paciente_id, SUM(...) FROM cargos WHERE clinica_id = $x GROUP BY paciente_id) agg ON agg.paciente_id = p.id`. Una pasada por tabla, join hash/merge.
- **LATERAL JOIN** para "primer registro por grupo" (próxima cita de cada paciente): `LEFT JOIN LATERAL (SELECT inicio FROM citas WHERE clinica_id = $x AND paciente_id = p.id ORDER BY inicio LIMIT 1) prox ON true`. El planner puede usar un índice por `(clinica_id, paciente_id, inicio)` → index range scan por paciente en lugar de seq scan.
- Regla: si ves `WHERE col_fk = tabla_outer.pk` dentro de un SELECT de la lista de columnas, reemplazar con JOIN.

**¿Específico de un stack?** No. Aplica a cualquier base de datos relacional (Postgres, MySQL, SQLite). En ORM aplica como "evitar N+1 queries" (eager loading / `include`).
