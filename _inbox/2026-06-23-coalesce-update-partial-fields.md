---
tipo: patron
titulo: COALESCE(new_value, existing_col) para actualizaciones parciales de perfil que no deben borrar campos vacíos
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Al añadir el campo `nombre` al formulario de membrete, si el usuario lo deja en blanco (no quiere cambiar el nombre), el server action recibe un string vacío. La función helper `s()` retorna `null` para valores vacíos. Sin COALESCE, un `UPDATE SET nombre = NULL` borraría el nombre existente.

**Causa raíz / por qué importa:** En formularios de edición de perfil/config, no todos los campos estarán rellenos siempre. Un UPDATE directo con el valor del formulario puede borrar datos válidos existentes cuando el campo se deja vacío. Es un bug de UX difícil de notar (el usuario solo ve que el nombre desapareció).

**Cómo aplicarlo / evitarlo:**
```sql
UPDATE tabla SET campo = COALESCE(${nuevo_valor_o_null}, campo) WHERE id = ${id}
```
- Si `nuevo_valor_o_null` es NOT NULL → actualiza con el nuevo valor.
- Si es NULL (campo vacío en el formulario) → `COALESCE(NULL, campo)` = `campo` (sin cambio).
- El helper `s()` (string vacío → null) + COALESCE es el patrón completo.
- No aplica para campos que sí deben poder borrarse (ej. notas opcionales); ahí un NULL explícito es válido.

**¿Específico de un stack?** No — aplica a cualquier BD que soporte COALESCE (SQL estándar).
