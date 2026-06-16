# Principio · Integridad de dinero y datos

**Regla:** el dinero se guarda como **entero en la unidad mínima** (centavos), nunca float. Datos con historia usan **soft-delete** (no borrado físico). Tablas inmutables/auditoría son **append-only**. En multi-tenant, **aislamiento desde la primera tabla** (cada fila lleva su tenant + política de fila + test de aislamiento).

**Por qué:** `0.1 + 0.2 !== 0.3` — con dinero eso es un bug contable. Borrar físico pierde trazabilidad. Una query sin filtro de tenant = fuga de datos entre clientes (severidad bloqueante).

**Cómo aplicarlo:** columnas enteras + formateo solo en presentación; `deleted_at` en vez de DELETE; `REVOKE UPDATE,DELETE` en tablas de auditoría; test que demuestre que un tenant no ve datos de otro.

Relacionado: [[no-datos-reales-de-usuarios]], [[auditar-modulo-vista-flujo]].
