---
tipo: bug
titulo: ul/li semántico es más robusto que role="list"+role="listitem" ante linters ARIA estáticos
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: Adaptadores/react-nextjs
---

**Qué pasó / contexto:**
En el dashboard de Denti, los "accesos rápidos" eran un `<div role="list">` con hijos `<Link role="listitem">`. El linter ARIA de VSCode/ESLint emitía error: "Required ARIA child role not present: listitem" — aunque en runtime `<Link>` renderiza como `<a>`, el linter analiza el JSX estáticamente y espera un elemento nativo `<li>`, no un componente de React.

**Causa raíz / por qué importa:**
Los linters ARIA son análisis estáticos — no resuelven qué renderiza un componente de React. Un `<div role="list">` con hijos que sean cualquier cosa que no sea `<li>` dispara el error, aunque en runtime el HTML final sea semánticamente correcto. El error bloquea auditorías de accesibilidad automatizadas.

**Cómo aplicarlo / evitarlo:**
Siempre preferir marcado semántico nativo sobre atributos `role`:

```tsx
// ❌ Rompe linters ARIA estáticos
<div role="list">
  <Link href="..." role="listitem">...</Link>
</div>

// ✅ Semántico, sin advertencias
<ul className={styles.grid}>  {/* list-style: none; padding: 0; margin: 0 en CSS */}
  <li><Link href="...">...</Link></li>
</ul>
```

El CSS para remover la bullet por defecto:
```css
.grid {
  list-style: none;
  padding: 0;
  margin: 0;
}
```

Regla general: usar `role="list"` solo cuando el elemento host no puede ser `<ul>/<ol>` (p.ej. un `<div>` que ya tiene otro significado semántico). En el 95% de los casos, `<ul>` es la solución correcta y más simple.

**¿Específico de un stack?** No — aplica a cualquier framework (React, Vue, Svelte) y cualquier herramienta de linting ARIA (axe, eslint-plugin-jsx-a11y, Lighthouse).
