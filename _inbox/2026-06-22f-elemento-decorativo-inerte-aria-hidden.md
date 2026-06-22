---
tipo: bug
titulo: Elemento visible que parece accionable pero es inerte — div aria-hidden sin Link/button
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** El avatar de iniciales del usuario en el header móvil de un dashboard era un `<div aria-hidden="true">`. Visualmente comunicaba identidad de usuario (círculo con iniciales, color de marca), lo que implícitamente sugiere que es tappable para acceder a la cuenta. Al tocarlo, no ocurría nada. La ruta de "Cerrar sesión" quedaba inaccessible sin esta acción.

El bug pasó desapercibido durante semanas porque:
1. En desktop el elemento estaba oculto (el menú de cuenta aparecía en la sidebar).
2. En móvil el usuario de prueba conocía rutas alternativas.
3. El aria-hidden suprimía el elemento en lectores de pantalla, así que no había alerta de accesibilidad automática.

**Causa raíz / por qué importa:** `aria-hidden="true"` en un elemento visible lo oculta del árbol de accesibilidad pero no lo hace invisible en pantalla. Un `<div>` sin `tabIndex`, `onClick`, `href` o `type="button"` es inerte por defecto — el navegador no lo trata como interactivo. El gap entre lo que el usuario percibe visualmente (un elemento con forma de botón) y lo que el navegador expone (nada) es una trampa clásica de UX/accesibilidad.

Este error aparece frecuentemente cuando:
- Un componente visual se diseña primero y la acción "se agrega después" (y no se agrega).
- Se copia un componente interactivo existente y se elimina la acción por error.
- Se usa `aria-hidden` para "silenciar" un elemento visualmente presente en lugar de hacerlo realmente inactivo.

**Cómo aplicarlo / evitarlo:**

**Regla:** Si un elemento es visible en pantalla y tiene apariencia de control (botón, avatar, ícono de acción), DEBE ser interactivo. No existe "decorativo pero con apariencia de botón".

Checklist antes de usar `aria-hidden="true"`:
- ¿El elemento es absolutamente invisible al usuario? (fondos, íconos puramente decorativos sin forma de control, separadores). Si no: no usar aria-hidden.
- ¿El elemento tiene forma de avatar, chip, badge o ícono de acción? → Debe ser `<Link>` o `<button>`. Punto.

Si el elemento NO debe ser interactivo aún (pendiente de implementar), usar `pointer-events: none; opacity: 0.4` para comunicar visualmente que está deshabilitado, no `aria-hidden`.

Fix estándar para avatar-como-link:
```tsx
// MAL: <div className={styles.avatar} aria-hidden="true">{iniciales}</div>
// BIEN:
<Link href="/cuenta" className={styles.avatar} aria-label="Mi cuenta">
  {iniciales}
</Link>
```
```css
.avatar {
  min-width: 44px;    /* touch target */
  min-height: 44px;
  text-decoration: none;
  -webkit-tap-highlight-color: transparent;
  /* resto del estilo visual */
}
```

**¿Específico de un stack?** No. El patrón (div inerte con apariencia de control) ocurre en cualquier stack web. El fix (Link/button + touch target) es universal. El aria-hidden mal usado es un anti-patrón W3C documentado.
