# Ficha de lección   [TRANSPORTABLE — formato de salida del CURADOR]

---
tipo: patron
titulo: Seed idempotente en migraciones SQL con DO block de guardia
proyecto_origen: Denti
fecha: 2026-06-27
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** En la migración 050 de Denti se necesitaba insertar datos de referencia (catálogo odontológico) para la primera clínica. El reto: la migración puede ejecutarse en múltiples entornos (dev, staging, prod) y podría re-aplicarse accidentalmente. Un INSERT sin guardia duplicaría filas.

**Causa raíz / por qué importa:** Las migraciones con seed no son idempotentes por defecto. Si se re-ejecuta el archivo SQL (por error de operaciones o en un restore), el INSERT duplica datos de referencia. Con RLS activo, los duplicados son visibles y confunden al usuario.

**Cómo aplicarlo / evitarlo:**

Envolver el seed en un bloque DO con una guardia explícita de existencia:

```sql
DO $$
DECLARE v_clinica_id UUID;
BEGIN
  SELECT id INTO v_clinica_id FROM clinicas WHERE deleted_at IS NULL ORDER BY created_at LIMIT 1;
  IF v_clinica_id IS NULL THEN RETURN; END IF;

  -- Guardia: solo insertar si aún no tiene datos
  IF EXISTS (SELECT 1 FROM mi_catalogo WHERE clinica_id = v_clinica_id) THEN
    RETURN;
  END IF;

  INSERT INTO mi_catalogo (...) VALUES (...), ...;
END $$;
```

Variante con `ON CONFLICT DO NOTHING` (cuando hay UNIQUE constraint):
```sql
INSERT INTO mi_catalogo (clinica_id, clave, ...)
VALUES (...) ON CONFLICT (clinica_id, clave) DO NOTHING;
```

Regla de oro: todo seed en una migración debe ser idempotente. Elegir DO block (para seed sin UNIQUE) u ON CONFLICT (cuando la clave lo garantiza).

**¿Específico de un stack?** Sí — PostgreSQL. En MySQL usar INSERT IGNORE o INSERT ... ON DUPLICATE KEY. En Prisma usar `upsert`. El principio es genérico: seed = idempotente.
