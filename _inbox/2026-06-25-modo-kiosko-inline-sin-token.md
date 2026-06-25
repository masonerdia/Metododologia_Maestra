---
tipo: patron
titulo: Modo kiosko inline sin token externo — el proveedor activa el formulario del cliente desde su sesión
proyecto_origen: Denti
fecha: 2026-06-25
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:**

El flujo original de Historia Clínica usaba un token UUID de un solo uso (4h TTL) que generaba una URL pública para que el paciente llenara el formulario desde su propio dispositivo. Esto introduce complejidad operacional: la doctora debe generar y compartir el token, el paciente debe abrir la URL, y hay una sesión paralela sin autenticación.

El HOTFIX-0028 reemplazó ese flujo por un wizard inline: la doctora activa "Modo Paciente" desde su sesión autenticada, el dispositivo (tablet/iPad del consultorio) muestra el wizard en un overlay full-screen que el paciente llena, y al terminar la doctora recupera el control con un PIN del consultorio.

**Causa raíz / por qué importa:**

El token externo agrega fricción innecesaria cuando el dispositivo ya está en manos del usuario final (el paciente en el consultorio). El modo kiosko inline simplifica el flujo, elimina la necesidad de compartir URLs, mantiene todo bajo la sesión de la doctora, y agrega una capa de seguridad (PIN de salida) sin complejidad de tokens.

Este patrón aplica a cualquier SaaS donde el proveedor de servicios entrega temporalmente su dispositivo a un cliente para que complete un formulario: recepción médica, check-in hotelero, firma de contratos en sitio.

**Cómo aplicarlo / evitarlo:**

1. **Overlay full-screen con z-index alto** (`position:fixed; inset:0; z-index:9999; background:white; overflow-y:auto`) para aislar visualmente al cliente del resto de la UI.
2. **Server actions con la sesión del proveedor** — el cliente no necesita sesión propia; las mutaciones corren bajo la autenticación del proveedor (clinicaId, etc.).
3. **PIN de salida** para devolver el control al proveedor. El cliente no puede cerrar el overlay sin el PIN del consultorio.
4. **Estado de completado** antes del PIN de salida — muestra pantalla de confirmación al cliente antes de la salida.
5. **Evitar**: generar tokens públicos cuando el dispositivo ya está físicamente bajo control del proveedor. El token externo solo vale si el cliente usa su propio dispositivo.

**¿Específico de un stack?** Sí — el overlay y el wizard son React/Next.js, pero el patrón (inline kiosko + PIN de salida + sesión del proveedor) es agnóstico al stack.
