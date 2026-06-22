---
tipo: patron
titulo: Validar constraints de negocio en la fase "preparar", no solo en "ejecutar"
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Al implementar `registrar_cargo` (asistente de voz), la regla de negocio "el descuento no puede ser ≥ al precio de lista" se validó en la fase `prepararEscritura`, devolviendo un mensaje de error conversacional (`tipo: 'falta'`) antes de mostrar la tarjeta de confirmación. La fase `ejecutarConfirmado` tiene re-validación defensiva via Zod, pero el constraint de negocio específico fue intencionalmente puesto en el prepare.

**Causa raíz / por qué importa:** En flujos de 2 fases (prepare → confirm → execute), hay dos niveles de validación con propósitos distintos:
- **Execute**: validación defensiva de tipo/forma (Zod schema) — garantiza que el payload no fue manipulado entre el client y el server. Protege contra bug/tampering.
- **Prepare**: validación de reglas de negocio — permite al usuario corregir en contexto conversacional. Si el descuento supera el precio, el prepare devuelve `{ tipo: 'falta', texto: '...' }` y el usuario puede aclararlo en la misma conversación sin haber "confirmado" nada. Si esta validación solo estuviera en el execute, el usuario confirmaría una acción que luego falla, creando una experiencia confusa.

**Cómo aplicarlo / evitarlo:**
En cualquier flujo de 2 fases con confirmación:
1. En **prepare**: valida las reglas de negocio que el usuario puede razonablemente violar (descuento > precio, fecha pasada, límite de caracteres excedido, celular de longitud incorrecta). Devuelve feedback conversacional (`tipo: 'falta'` con `texto` explicativo) para que el usuario corrija.
2. En **execute**: valida solo forma/tipo (Zod, UUIDs, rangos numéricos) como red de seguridad. No re-valida lógica de negocio compleja que requiere volver a la BD — confiar en el payload del prepare.
3. Regla de oro: si la validación fallida requiere una respuesta del usuario → prepare. Si la validación es un assert de seguridad → execute.

**¿Específico de un stack?** No — patrón general de flujos command/confirmation. Aplica a cualquier sistema con paso de confirmación explícita antes de mutación (CQRS, chatbots, wizards multi-paso, etc.).
