# Ficha de lección   [TRANSPORTABLE — formato de salida del CURADOR]

---
tipo: patron
titulo: Catálogos configurables por tenant en lugar de enums globales en SaaS
proyecto_origen: Denti
fecha: 2026-06-27
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Denti necesitaba un catálogo de regiones anatómicas para la exploración clínica (mucosa, encías, ATM, etc.). La primera opción era un enum global en PostgreSQL o una tabla de lookup global. Se descartó en favor de una tabla por clínica (`exploracion_opcion` con `clinica_id`).

**Causa raíz / por qué importa:** Un SaaS multi-especialidad no puede asumir que todos los clientes tienen el mismo vocabulario clínico. Una clínica odontológica tiene "ATM / oclusión / encías"; una ortopédica tiene "columna / rodilla / hombro". Un enum global obliga a todos los tenants al mismo conjunto, imposibilitando la configuración por especialidad.

**Cómo aplicarlo / evitarlo:**

Diseño de catálogo configurable por tenant:

```sql
CREATE TABLE mi_catalogo (
  id         UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  clinica_id UUID NOT NULL REFERENCES clinicas(id),   -- tenant
  clave      TEXT NOT NULL,    -- identificador de categoría
  etiqueta   TEXT NOT NULL,    -- nombre visible
  es_default BOOLEAN NOT NULL DEFAULT false,
  orden      INT  NOT NULL DEFAULT 0,
  deleted_at TIMESTAMPTZ NULL  -- soft-delete
);

-- RLS: cada tenant ve solo los suyos
ALTER TABLE mi_catalogo ENABLE ROW LEVEL SECURITY;
CREATE POLICY tenant ON mi_catalogo TO app_role
  USING (clinica_id = NULLIF(current_setting('app.clinica_id', true), '')::uuid);
```

- Seed inicial: un DO block por cliente (o la doctora/admin configura desde UI).
- La UI permite agregar/editar/archivar opciones sin deploy.
- `es_default = true` preselecciona la opción estándar (en Denti: "Normal" para una exploración sana).
- Combinado con soft-delete: archivar una opción la oculta sin romper datos históricos que la referenciaron.

**Cuándo NO usar:** catálogos que son estándar legal (CIE-10, CFDI SAT) — esos van globales y no son editables por el tenant.

**¿Específico de un stack?** No — es un patrón de diseño multi-tenant aplicable a cualquier base de datos relacional con RLS o filtro de tenant.
