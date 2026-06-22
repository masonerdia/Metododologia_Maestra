---
tipo: patron
titulo: Append materializado en flujo de confirmación — pasar el valor completo, no el delta
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Se implementó `anotar_nota_paciente` (asistente de voz) que debía *añadir* texto a una nota existente, no sobrescribirla. Existía ya un server action `editarNotaPaciente` que solo sobreescribía. La solución no fue extender ese action sino aplicar el patrón correcto para flujos de 2 fases (preparar → confirmar → ejecutar).

**Causa raíz / por qué importa:** En un flujo con tarjeta de confirmación, pasar solo el delta (el texto nuevo) al step de confirmación crea dos problemas: (1) el usuario no ve en la tarjeta el resultado final — solo ve "añadir X", no "nota quedará como: ...X", y (2) hay una ventana de carrera entre el read que hiciste en "preparar" y el momento en que se ejecuta tras la confirmación — si alguien modifica la nota entre medias, tu "append" sobrescribe cambios.

**Cómo aplicarlo / evitarlo:**
En cualquier operación de tipo append sobre un campo de texto:
1. En la fase **preparar**: lee el valor actual de la BD (`SELECT campo FROM tabla WHERE ...`).
2. Construye `valorNuevo = valorActual ? valorActual + separador + delta : delta`.
3. Valida el resultado completo (ej. `valorNuevo.length ≤ maxChars`).
4. Pasa `valorNuevo` (no el delta) al payload de la AccionConfirmable.
5. En la fase **ejecutar**: escribe `SET campo = valorNuevo` directamente.

La fase ejecutar se convierte en una operación idempotente (escribe un valor ya calculado), no en una operación de lectura-modificación-escritura en dos transacciones. La tarjeta de confirmación muestra lo que el usuario confirma, no una abstracción.

**¿Específico de un stack?** No — aplica a cualquier flujo "prepare → confirm → execute" con campos acumulativos (notas, historial, tags, listas). Agnóstico al lenguaje/framework.
