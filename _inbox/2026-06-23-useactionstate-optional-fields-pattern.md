# Ficha de lección

---
tipo: patron
titulo: useActionState — campos opcionales en lugar de discriminated union evita narrowing TS
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: Adaptadores/nextjs-react
---

**Qué pasó / contexto:**

En DENTI-0048 CAPA 0, el tipo de estado de `useActionState` se definió como `{ ok: true } | { error: string } | null` — un discriminated union. TypeScript no deja acceder a `.ok` en el variante `{ error }` ni a `.error` en el variante `{ ok }`. El código necesitaba `state?.ok` y `state?.error` en el mismo render sin narrowing explícito (para mostrar el error O redirigir al éxito).

**Causa raíz / por qué importa:**

El discriminated union es correcto semánticamente, pero en la práctica de `useActionState` el estado previo puede ser `null`, `ok`, o `error` en cualquier momento del ciclo de render. Añadir un `if ('ok' in state)` para cada rama genera código verboso en los Client Components de formulario.

**Cómo aplicarlo / evitarlo:**

Usar campos opcionales en lugar de discriminated union para estados de server action en React:

```typescript
// ✅ Patrón recomendado — ambos campos accesibles sin narrowing
type ActionState = { ok?: true; error?: string } | null;

// En el componente:
if (state?.ok) router.refresh();
if (state?.error) return <p>{state.error}</p>;

// ❌ Evitar — requiere narrowing en cada uso
type ActionState = { ok: true } | { error: string } | null;
```

Funciona porque `ok?: true` y `error?: string` son siempre opcionalmente accesibles; el `?` en `state?.ok` ya hace el null-check. Si la acción devuelve `{ ok: true }` el campo `error` es `undefined`, no un error de tipo.

**¿Específico de un stack?** Sí — Next.js App Router con `useActionState` (React 19+). El patrón es válido en cualquier contexto donde un estado de formulario necesita discriminar éxito/error sin narrowing de TypeScript.
