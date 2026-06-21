---
tipo: patron
titulo: tool_choice:'any' + pseudo-tool catch-all para garantizar structured output en Anthropic API
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: Adaptadores/llm-anthropic
---

**Qué pasó / contexto:** El asistente IA de Denti usaba `tool_choice: 'auto'` al llamar a la Anthropic API con claude-haiku-4-5. Para peticiones ambiguas o formuladas como preguntas, el modelo devolvía texto libre en lugar de llamar una herramienta (`tool_use`). El código asumía que la respuesta siempre era una tool y fallaba silenciosamente (o con error de tipo) cuando recibía un bloque de texto.

**Causa raíz / por qué importa:** `tool_choice: 'auto'` da al modelo la opción de responder con texto libre. Los modelos pequeños (Haiku) especialmente tienden a hacerlo cuando no ven una tool que encaje claramente. Con `auto`, el contrato entre el orquestador y el modelo es ambiguo: el código nunca puede asumir que habrá un `tool_use` block. Esto es difícil de detectar porque solo falla en producción con ciertos inputs.

**Cómo aplicarlo / evitarlo:**
1. Usar `tool_choice: { type: 'any' }` en lugar de `auto` cuando el orquestador SIEMPRE espera una respuesta estructurada.
2. Añadir una pseudo-tool `responder_texto` (o similar) que actúa como catch-all: el modelo la usa para aclaraciones, datos faltantes y fuera-de-alcance. Tiene un campo `texto: string`. Esto garantiza que con `any` el modelo siempre tenga una tool que llamar.
3. Listar explícitamente las tools disponibles en el system prompt y añadir la instrucción "SIEMPRE llama exactamente UNA herramienta".
4. En el orquestador: manejar `responder_texto` como respuesta de texto al usuario (sin efecto secundario), y el resto como acciones reales.

```typescript
// Pseudo-tool catch-all
const TOOL_TEXTO: Anthropic.Tool = {
  name: 'responder_texto',
  description: 'Responde al usuario con texto: aclaración, dato faltante, o fuera de capacidades.',
  input_schema: {
    type: 'object' as const,
    properties: { texto: { type: 'string' } },
    required: ['texto'],
    additionalProperties: false,
  },
};

// En la llamada a la API:
tool_choice: { type: 'any' },
tools: [...TOOLS, TOOL_TEXTO],
```

**¿Específico de un stack?** Sí — Anthropic API / Claude SDK. La lógica es aplicable a otros LLMs con llamadas a herramientas (OpenAI function calling tiene `tool_choice: 'required'` que es el equivalente directo; Gemini tiene `ANY`).
