---
tipo: patron
titulo: CSS custom property para colores dinámicos de BD — evita linter inline-style
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: Adaptadores/react-nextjs
---

**Qué pasó / contexto:**
En el dashboard de Denti, cada cita muestra un "dot" de color que viene de `profesional.color` (columna `TEXT` en BD, valor hexadecimal como `#3B82F6`). La implementación obvia era `style={{ background: dbColor }}` pero el linter de VSCode/ESLint emite warning "CSS inline styles should not be used, move styles to an external CSS file".

**Causa raíz / por qué importa:**
Los valores de color provienen de la BD en runtime — no pueden ir en un CSS module estático. El linter no puede distinguir entre "inline style innecesario" (donde una clase estática bastaría) y "inline style necesario" (donde el valor es dinámico). Ignorar la advertencia genera ruido; suprimirla con `/* eslint-disable */` es ruidoso y oculta casos reales.

**Cómo aplicarlo / evitarlo:**
Usar CSS custom property como puente entre el valor dinámico de JS y el CSS module:

En JSX:
```tsx
<span
  style={{ '--dot-color': dbColor } as React.CSSProperties}
  className={styles.dot}
/>
```

En el CSS module:
```css
.dot {
  background: var(--dot-color, var(--color-fallback));
}
```

Resultado: el linter ve `style` asignando una custom property (no un valor de estilo directo) → no emite warning. El CSS module define la propiedad visual. El cast `as React.CSSProperties` es necesario porque TypeScript no tipea `--*` por defecto. El fallback en `var()` es gratis.

Este patrón es idéntico al de barras de progreso con `--barH`/`--barW` (ya en uso en /finanzas y /metricas).

**¿Específico de un stack?** Sí — React + CSS Modules + TypeScript. El cast `as React.CSSProperties` es específico de TypeScript; en JS puro no se necesita.
