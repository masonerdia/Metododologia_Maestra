---
tipo: bug
titulo: Elegir candidato por ID, no por nombre — evitar bucle en desambiguación
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** El asistente de voz de Denti mostraba botones para elegir entre dos pacientes homónimos. Al hacer clic, el botón enviaba el NOMBRE del candidato como un nuevo mensaje de texto. El LLM re-interpretaba el mensaje, volvía a llamar la misma tool y resolverPaciente encontraba los mismos homónimos → devolvía de nuevo los botones → bucle infinito.

**Causa raíz / por qué importa:** La desambiguación por nombre es inherentemente inestable cuando el nombre es precisamente la fuente de la ambigüedad. Re-ejecutar la resolución con el mismo input textual solo puede producir el mismo resultado ambiguo. El problema no es la resolución en sí — es que el resultado de elegir (el nombre) vuelve a entrar al mismo proceso de resolución.

**Cómo aplicarlo / evitarlo:**

Patrón correcto en cualquier flujo de desambiguación:

1. **La UI guarda el pendiente completo** (qué acción se iba a ejecutar + con qué parámetros). El botón de elección NO re-envía el texto — llama directamente un handler que tiene el ID del candidato seleccionado.

2. **El servidor recibe el ID, no el nombre.** Con el ID, puede cargar el recurso directamente (SELECT WHERE id = $1) sin volver a pasar por el proceso de resolución fuzzy.

3. **La lista de candidatos incluye datos distintivos** (celular, fecha de nacimiento, email) para que el usuario pueda distinguir homónimos visualmente.

Implementación concreta (Denti):
- `Preparacion 'candidatos'` incluye `detalle: string | null` (celular) por candidato.
- `RespuestaAsistente 'candidatos'` incluye `pendingNombre` y `pendingParams` (la acción que quedó pendiente).
- Botón candidato llama `elegirCandidato(pendingNombre, pendingParams, c.id)` → server action que usa `resolverPacientePorId(id)` (SELECT directo) en lugar de `resolverPaciente(nombre)` (fuzzy search).
- Aplica tanto a ESCRITURAS como a LECTURAS que desambiguan.

**¿Específico de un stack?** No. El patrón es universal: en cualquier UI con flujo de desambiguación (buscadores, asistentes, formularios con autocompletado), la elección del candidato debe usar un identificador estable (ID, UUID, slug), nunca re-enviar el texto que originó la búsqueda.
