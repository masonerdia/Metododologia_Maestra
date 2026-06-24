# Ficha de lección   [TRANSPORTABLE — formato de salida del CURADOR]

> El agente CURADOR genera una de estas por lección y la deja en `_inbox/`. Tú la revisas y, si es buena, la promueves al lugar canónico (00-Principios / 03-Gates / 04-Auditorias / adaptador) y la registras en el CHANGELOG. Si no, se borra.

---
tipo: patron
titulo: ALTER TABLE ADD COLUMN en PostgreSQL con RLS hereda las políticas existentes — no requiere nueva política
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** En GIIS-VARS (Denti) se añadieron tres columnas nuevas (`clues`, `tipo_consulta`, `procedimiento_cmgpc`) a tablas existentes (`clinicas`, `evaluacion`) que ya tenían Row Level Security habilitado y políticas RLS configuradas. La pregunta era: ¿hay que añadir nuevas políticas RLS para las columnas nuevas?

**Causa raíz / por qué importa:** En PostgreSQL, las políticas RLS operan a nivel de **fila**, no de columna. Al hacer `ALTER TABLE ADD COLUMN`, la columna nueva es accesible solo para las mismas filas que ya pasan la política existente. No existe un concepto de "política de columna" en PostgreSQL RLS — eso pertenece a column-level privileges (GRANT SELECT(col)), que es un mecanismo distinto. Por tanto, añadir una columna a una tabla con RLS no requiere modificar ni crear políticas: la restricción de fila ya aplica automáticamente a todos los campos, incluidos los nuevos.

**Cómo aplicarlo / evitarlo:**
- `ALTER TABLE t ADD COLUMN nueva_col TEXT` → RLS existente cubre la columna automáticamente.
- Solo necesitas nuevas políticas si creas una **nueva tabla** (que empieza sin políticas) o si cambias el **criterio de filtrado de filas**.
- Si necesitas ocultar columnas específicas de ciertos roles (column-level), usa `GRANT SELECT(col1, col2) ON tabla TO rol` y `REVOKE SELECT ON tabla FROM rol` — eso es ortogonal a RLS.
- Checklist: al hacer ADD COLUMN en tabla con RLS, verificar solo que los GRANT de tabla (INSERT/SELECT/UPDATE/DELETE) siguen correctos para el rol de aplicación; no hace falta tocar `CREATE POLICY`.

**¿Específico de un stack?** Sí — PostgreSQL (aplica a todas las versiones ≥ 9.5 con RLS). No aplica a MySQL, SQLite u otros motores sin RLS nativo.
