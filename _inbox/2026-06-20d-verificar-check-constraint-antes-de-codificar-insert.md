---
tipo: bug
titulo: Verificar CHECK constraints de BD antes de hardcodear strings en INSERT/UPDATE
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 03-Gates
---

**Qué pasó / contexto:** El asistente IA de Denti usaba el valor `'programada'` como estado al insertar una cita en la BD. La tabla `citas` tiene un CHECK constraint que solo acepta `agendada|confirmada|asistio|no_asistio|cancelada|reagendada`. El INSERT fallaba siempre con `violates check constraint` — una excepción de Postgres que el handler de la tool silenciaba como error genérico. El asistente nunca agendaba una cita y no había mensaje de error visible para el usuario.

**Causa raíz / por qué importa:** El desarrollador asumió que `'programada'` era un estado válido sin revisar el schema real de la tabla. La violación de constraint no se propagó como error visible al usuario (se silenciaba). El error tampoco era detectable por `tsc --noEmit` ni por `next build` — solo reventaba en runtime contra la BD. Este patrón (hardcodear un string "que parece razonable" sin verificar el enum de BD) es una fuente recurrente de bugs silenciosos.

**Cómo aplicarlo / evitarlo:**
1. **Antes de escribir un INSERT/UPDATE con un string literal**, ejecutar `\d nombre_tabla` en psql para ver el CHECK constraint del campo.
2. Preferir constantes tipadas en TypeScript que reflejen los valores permitidos (ej. `type EstadoCita = 'agendada' | 'confirmada' | ...`) para que tsc detecte valores inválidos en tiempo de compilación.
3. En tests de integración, incluir un caso que inserte el estado inicial y verificar que el INSERT no falla — detecta regresos de constraints.
4. Si el enum vive en la BD (CHECK constraint) y no en TypeScript, hacer que el tipo TS espeje el constraint y actualizar ambos en sintonía cuando cambie.

**¿Específico de un stack?** No — aplica a cualquier proyecto con SQL + TypeScript (o cualquier lenguaje tipado). La disciplina de consultar el schema antes de hardcodear valores es universal.
