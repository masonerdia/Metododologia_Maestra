---
tipo: patron
titulo: Re-validación defensiva entre preparar y confirmar en two-phase writes
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** En el asistente de Denti, hay dos fases: `prepararEscritura()` (resuelve paciente, detecta conflictos, muestra tarjeta de confirmación al usuario) y `ejecutarConfirmado()` (escribe en BD). El usuario puede tardar varios segundos en confirmar. Si otro usuario agenda el mismo horario en ese intervalo, `ejecutarConfirmado()` escribiría un doble-booking.

**Causa raíz / por qué importa:** En cualquier sistema con flujo prepare→confirm (reservas, agendas, carritos de compra, aprobaciones), el recurso puede ser tomado entre la fase de lectura/validación y la escritura. Confiar en la validación de `preparar` es un race condition latente.

**Cómo aplicarlo / evitarlo:**
1. En `ejecutarConfirmado` (el punto de escritura), siempre re-validar el recurso crítico con los datos más recientes de la BD — no asumir que la tarjeta de confirmación sigue siendo válida.
2. Si la re-validación falla, devolver `{ ok: false, mensaje: "El horario fue tomado mientras confirmabas. Intenta de nuevo." }` — no procesar la escritura.
3. El costo es una query extra (barata) antes de un INSERT/UPDATE — completamente justificado.
4. Pattern: `const choque = await conflicto(clinicaId, new Date(a.inicioISO), new Date(a.finISO)); if (choque) return { ok: false, ... };`

**¿Específico de un stack?** No. Aplica a cualquier sistema con two-phase commit a nivel de aplicación (no confundir con two-phase commit distribuido). En SQL se puede reforzar con `SELECT FOR UPDATE` o en PostgreSQL con `ON CONFLICT DO NOTHING RETURNING id`.
