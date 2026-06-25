---
tipo: patron
titulo: PIN guard se aplica también a ediciones de datos sensibles, no solo a eliminaciones
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:**
En DENTI-0060 se implementó PIN guard para acciones destructivas (eliminar cita, eliminar abono, eliminar paciente). En DENTI-0062 se extendió el mismo patrón a ediciones de datos sensibles: editar nombre/celular/email del paciente y editar datos fiscales (RFC, razón social, C.P., régimen, uso CFDI).

**Causa raíz / por qué importa:**
Las ediciones de datos sensibles son tan críticas como las eliminaciones desde el punto de vista de auditoría y compliance: cambiar el RFC de un paciente puede anular facturas previas; cambiar el celular puede desviar mensajes a un tercero. En un sistema multi-rol (duena + asistente), el PIN actúa como una segunda capa de autorización que previene cambios accidentales o no autorizados por parte del asistente con acceso al dispositivo.

**Cómo aplicarlo / evitarlo:**
Al clasificar acciones que requieren PIN, no limitarse a "eliminar": incluir ediciones de datos de identidad (nombre, teléfono, email) y datos fiscales/financieros. Patrón en React/Next.js: `handleSubmit` previene el comportamiento nativo del formulario (`e.preventDefault()`), muestra `PinModal`, y al confirmar reensambla el `FormData` con `fd.set('pin_confirmacion', pin)` y llama `dispatch(fd)`. La acción server-side llama `requierePin(pin)` antes de cualquier UPDATE. Para formularios de creación (primer alta), el PIN no aplica porque no hay dato previo que proteger.

**¿Específico de un stack?**
Sí — la implementación usa `useActionState` + `FormData` de Next.js App Router. El principio (PIN para ediciones sensibles, no solo destructivas) es genérico.
