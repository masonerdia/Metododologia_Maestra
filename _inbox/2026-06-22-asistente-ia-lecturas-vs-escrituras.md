---
tipo: patron
titulo: "Asistente IA: herramientas LECTURA (automáticas) vs. ESCRITURA (confirmación explícita)"
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: Adaptadores/IA-asistente
---

**Qué pasó / contexto:** Al ampliar un asistente de voz con nuevas capacidades, surgió la necesidad de distinguir herramientas de solo lectura (ver agenda, consultar saldo) de herramientas que mutan datos (cancelar cita, registrar abono). Las lecturas son seguras de ejecutar inmediatamente; las escrituras pueden causar daño irreversible si el modelo malinterpreta el input de voz.

**Causa raíz / por qué importa:** Con voz, el reconocimiento de texto nunca es perfecto. Un asistente que ejecuta escrituras sin confirmación puede cancelar citas, registrar cobros o eliminar datos basado en un audio mal transcrito. La confirmación explícita es la barrera entre "entendí lo que dijiste" y "voy a hacerlo".

**Cómo aplicarlo / evitarlo:**
- **Definición formal:** mantener un `Set<NombreTool>` de herramientas de ESCRITURA. Al recibir la intención del LLM, verificar primero si la herramienta está en ese set.
- **Flujo para LECTURAS:** ejecutar directo → devolver resultado al usuario.
- **Flujo para ESCRITURAS:** preparar resumen legible (qué acción, sobre qué entidad, con qué parámetros) → mostrar tarjeta de confirmación → esperar aprobación explícita → ejecutar.
- **Regla de oro:** cualquier acción que modifica datos persistentes (INSERT/UPDATE/DELETE) es ESCRITURA. Cualquier SELECT puro es LECTURA. No hay zona gris.
- **Beneficio colateral:** la confirmación sirve como corrección de errores — el usuario ve el resumen ("Cancelar cita de [Nombre] el [fecha]") y puede detectar si el modelo entendió mal el nombre o la fecha.

**¿Específico de un stack?** No — es un patrón de diseño de producto para cualquier asistente IA con function-calling (OpenAI, Anthropic, Gemini) donde las acciones tienen efectos secundarios.
