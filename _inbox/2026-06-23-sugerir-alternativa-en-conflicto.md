---
tipo: patron
titulo: Sugerir alternativa disponible en lugar de rechazar cuando hay conflicto de recurso
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Al agendar una cita por voz, si el horario pedido está ocupado, la versión original simplemente devolvía un error ("ese horario ya está tomado"). El usuario tenía que preguntar manualmente por otro horario. En DENTI-0044 se cambió para que, en lugar de rechazar, el sistema calcule el siguiente hueco disponible y lo proponga directamente en la misma respuesta.

**Causa raíz / por qué importa:** Un error puro ("no disponible") obliga al usuario a hacer una segunda solicitud. En interfaces de voz o asistentes esto es especialmente costoso — el usuario tiene que reformular, el asistente tiene que re-interpretar. Si el sistema ya tiene los datos para proponer una alternativa, hacerlo en la misma respuesta elimina un round-trip completo.

**Cómo aplicarlo / evitarlo:**
- Cuando hay un conflicto de recurso (horario ocupado, stock insuficiente, cupo lleno), verificar si el sistema puede calcular una alternativa válida (siguiente hueco, producto alternativo, fecha siguiente con disponibilidad).
- Si hay alternativa: presentarla como una propuesta que el usuario puede confirmar con una sola palabra ("sí" / "confirmar").
- Si no hay alternativa en N intentos/días/unidades: entonces sí devolver el error.
- Estructura del resultado: `{ tipo: 'confirmar', resumen: "Las 10:00 está ocupado. El próximo hueco libre es martes 10:30 — ¿lo agendo ahí?", accion: { tipo: 'agendar_cita', ...slots_alternativos } }`
- El action contiene los datos del slot alternativo, no del pedido original. Cuando el usuario confirma, se escribe el slot correcto.

**¿Específico de un stack?** No. Aplica a cualquier UI/UX donde hay conflicto de recurso: reservas, carritos, agendas, asignación de salas. El patrón es: detectar conflicto → buscar alternativa → proponer en lugar de rechazar.
