---
tipo: bug
titulo: aria-pressed requiere string 'true'/'false' en JSX — las expresiones booleanas dinámicas son rechazadas por jsx-a11y
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: Adaptadores/React
---

**Qué pasó / contexto:** Se añadieron botones de filtro con `aria-pressed={expresion}` donde la expresión era booleana (ej. `filtro === val`). El linter (jsx-a11y) emitía un error de severidad "Error": `ARIA attributes must conform to valid values: Invalid ARIA attribute value: aria-pressed="{expression}"`.

**Causa raíz / por qué importa:** La regla jsx-a11y/aria-proptypes verifica que los valores ARIA sean los aceptados por el spec WAI-ARIA. Para `aria-pressed`, los valores válidos son los literales `"true"`, `"false"` o `"mixed"` (strings). Cuando JSX pasa una expresión dinámica (`{booleano}`), el linter no puede verificar que el resultado siempre sea un valor válido, y lo rechaza. En el DOM real React convierte `true`→`"true"` y `false`→`"false"`, pero el linter no llega a ese punto.

**Cómo aplicarlo / evitarlo:**

En lugar de:
```tsx
aria-pressed={condicion}
```

Usar:
```tsx
aria-pressed={condicion ? 'true' : 'false'}
```

Esto pasa un string literal que jsx-a11y puede validar estáticamente. La semántica HTML es idéntica porque los atributos ARIA siempre son strings en el DOM.

Aplica a todos los atributos `aria-*` con valores enumerados: `aria-expanded`, `aria-selected`, `aria-checked`, `aria-pressed`, `aria-hidden`.

**¿Específico de un stack?** Sí — jsx-a11y (linter de React/JSX). En Vue/Angular el binding es diferente y los linters tienen sus propias reglas, pero el principio "los valores ARIA son strings, no booleans JS" es universal.
