---
tipo: bug
titulo: Migración de datos con WHERE condicional falla silenciosamente en prod si las condiciones se diseñaron sobre datos de dev/seed
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** migración 038 hacía `UPDATE clinicas SET logo_path = '...' WHERE logo_path = '/brand/.../demo-logo.png' OR telefono = '5512345678' OR cedula_profesional = 'Cedula'`. En dev las condiciones coincidían con el seed demo. En producción (clínica real) los valores eran distintos → 0 filas actualizadas → logo/cédula/dirección/tel vacíos en receta y justificante. El dueño tuvo que aplicar el UPDATE manualmente.

**Causa raíz / por qué importa:** Las migraciones de datos suelen escribirse mirando el seed de dev, no el estado real de prod. Si la migración es condicional ("solo actualiza si el valor es X") y X no existe en prod, la migración se ejecuta sin error pero sin efecto — y no hay señal de que falló. Es un fallo silencioso difícil de detectar.

**Cómo aplicarlo / evitarlo:**
1. **Preferir UI idempotente sobre migración one-shot para datos de configuración:** si el dato que quieres inicializar va a cambiar (logo, teléfono, nombre del médico), mejor exponer un editor en la app que funcione en cualquier estado de la BD.
2. **Si debes usar una migración de datos:** hazla sin WHERE o con WHERE que solo excluya estados claramente inválidos (`WHERE col IS NULL`). Documenta el estado que asume en el comentario de la migración.
3. **Para datos de clinic-config:** la URL de impresión, el logo, el teléfono de la clínica, etc., siempre deben poder editarse desde la UI. La migración solo siembra un valor default; la UI es el mecanismo permanente.

**¿Específico de un stack?** No — aplica a cualquier proyecto con migraciones de datos (SQL, NoSQL, ORM).
