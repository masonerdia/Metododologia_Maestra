---
tipo: patron
titulo: Gráficas de barras CSS sin librería — custom properties como ejes dinámicos
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Necesitábamos gráficas de barras (ingresos vs egresos por mes, categorías de gasto, métodos de pago) en una app mobile-first sin dependencias de Recharts/Chart.js/D3. Añadir una librería de gráficas habría sumado >100 KB al bundle y una API compleja innecesaria.

**Causa raíz / por qué importa:** Las librerías de gráficas son overkill para visualizaciones simples del tipo "barras coloreadas proporcionales a un valor". CSS puro con custom properties es más pequeño, más rápido, y accesible al servidor (sin `'use client'`).

**Cómo aplicarlo / evitarlo:** Pasar el porcentaje como CSS custom property desde JSX y referenciarlo en el CSS:

```tsx
// JSX: el % ya calculado en JS, no en CSS
const max = Math.max(...items.map(r => r.valor), 1);
<div
  className={styles.bar}
  style={{ '--barH': `${Math.round((item.valor / max) * 100)}%` } as React.CSSProperties}
/>
```

```css
/* CSS: usa la variable, con fallback y min-height para 0 */
.bar {
  height: var(--barH, 0%);
  min-height: 2px;          /* visible incluso con valor 0 */
  transition: height 0.3s ease;
}
```

Para barras horizontales: `width: var(--barW, 0%)`. El contenedor debe tener `align-items: flex-end` (barras verticales alineadas al suelo) y `overflow-x: auto; scrollbar-width: none` para scroll horizontal en mobile.

**¿Específico de un stack?** No — funciona en cualquier framework que soporte inline styles como objeto (React, Vue, Svelte). El patrón es CSS puro.
