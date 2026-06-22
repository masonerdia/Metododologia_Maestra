---
tipo: patron
titulo: Parseo de lenguaje natural de fecha/hora a timestamptz en un asistente de voz
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: Adaptadores/asistente-voz
---

**Qué pasó / contexto:** Se implementó `bloquear_agenda` en el asistente de voz, que requiere parsear expresiones como "el viernes de 2 a 4" o "todos los días de 2 a 3" en parámetros estructurados (fecha ISO, horaInicio HH:mm, horaFin HH:mm, días de semana). El LLM (Haiku) extrae los parámetros; el servidor los valida y convierte a `timestamptz`.

**Causa raíz / por qué importa:** Hay tres capas de trabajo diferenciadas que no se deben mezclar:
1. **LLM**: extrae intención + parámetros crudos (fecha ISO, hora HH:mm 24h, array de días). NO parsea a Date.
2. **Preparer** (server-side): combina fecha + hora + offset → `Date`, valida coherencia (fin > inicio), construye el payload confirmable con timestamps ya calculados.
3. **Executor** (tras confirmación): solo hace el INSERT con los timestamps ya construidos — es idempotente.

Si el LLM intenta construir timestamps directamente, mezcla zona horaria y formatos de manera poco confiable. Si el executor recalcula desde la hora original, hay una ventana de carrera (la fecha "hoy" puede haber cambiado entre preparer y executor).

**Cómo aplicarlo / evitarlo:**
- Diseñar los schemas de function-calling con tipos primitivos simples: `fecha: string (YYYY-MM-DD)`, `hora: string (HH:mm)`. El LLM convierte "el viernes" → ISO date, "2 a 4" → "14:00"/"16:00" con un hint en el prompt.
- En el preparer: combinar con el offset fijo de la zona horaria (`new Date(\`${fecha}T${hora}:00${MX_OFFSET}\`)`) y validar antes de mostrar la tarjeta.
- Pasar el ISO timestamp (no la fecha+hora separadas) al AccionConfirmable → el executor solo usa ese timestamp.
- Hint en el system prompt: `"en horario laboral '2 a 4' = 14:00–16:00"` — el modelo necesita contexto para desambiguar AM/PM en 24h.

**¿Específico de un stack?** Parcialmente: el patrón LLM-extrae/server-parsea es genérico. El uso de `MX_OFFSET = '-06:00'` y `new Date(\`...-06:00\`)` es específico de México. Adaptable a cualquier timezone con su propio offset.
