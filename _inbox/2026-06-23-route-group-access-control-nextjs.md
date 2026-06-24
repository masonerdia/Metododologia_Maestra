# Ficha de lección

---
tipo: patron
titulo: Route group con layout como gate transitivo de acceso en Next.js App Router
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: Adaptadores/nextjs-react
---

**Qué pasó / contexto:**

En DENTI-0048, se necesitaba que `/finanzas`, `/gastos` y `/facturacion` estuvieran restringidas a `rol === 'duena'` + un PIN de desbloqueo. En lugar de añadir el check en cada `page.tsx`, se creó el route group `(admin)` con un `layout.tsx` que centraliza ambas verificaciones.

**Causa raíz / por qué importa:**

Repetir el gate de rol en cada `page.tsx` es frágil: un nuevo módulo olvida el check y queda sin protección. Un route group `(admin)/layout.tsx` aplica el gate **una sola vez** a todas las rutas bajo él — incluso las que se crean en el futuro. El nombre del group con paréntesis `(admin)` **no agrega segmento a la URL** (Next.js App Router: los route groups con `()` son solo agrupadores de layout, transparentes en la URL).

**Cómo aplicarlo / evitarlo:**

```
app/
  (app)/
    (admin)/           ← route group — no agrega /admin/ a la URL
      layout.tsx       ← Gate: rol + PIN → aquí y solo aquí
      finanzas/
        page.tsx       ← hereda el gate automáticamente
      gastos/
        page.tsx       ← hereda el gate automáticamente
    dashboard/
      page.tsx         ← no en (admin) → no tiene gate
```

El `layout.tsx` del route group:
1. Llama `getSesionClinica()` — una sola vez
2. Verifica `sesion.rol !== 'admin_role'` → `redirect('/fallback')`
3. Verifica cookie/sesión adicional si hay 2FA o PIN → renderiza `<UnlockScreen>` en lugar de `children`
4. Si todo OK → `return <>{children}</>`

Cualquier nueva página bajo `(admin)/` hereda la protección sin código adicional.

**Truco de robustez:** también añadir el check en las server actions que mutan datos (defensa en profundidad), porque un route handler o API podría no pasar por el layout.

**¿Específico de un stack?** Sí — Next.js App Router (v13+). El concepto general (middleware/guard de acceso transitivo por grupo de rutas) aplica a cualquier framework con route grouping.
