---
tipo: patron
titulo: "Hint state" — barrera de carga diferida para listas largas en mobile-first
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Una pantalla de CRM listaba 914 registros al montar el componente. En móvil, renderizar cientos de filas de golpe produce lag de hydration + scroll pesado + memoria alta. Se añadió una barra de filtro alfabético (A–Z) pero la clave era el estado default: sin filtro activo, NO renderizar la lista — mostrar solo el hint "Elige una letra o busca" y la barra de selección.

**Causa raíz / por qué importa:** El error de diseño es asumir que el usuario necesita ver todos los registros inmediatamente. En el 95% de los flujos reales el usuario sabe lo que busca: un nombre, una letra inicial, un filtro. Mostrar todos los registros antes de que haga algo es trabajo de CPU/RAM sin beneficio real.

**Cómo aplicarlo / evitarlo:**

Patrón "hint state":
1. El estado inicial (`sin filtro + sin búsqueda`) → renderiza CERO registros + mensaje de orientación.
2. El usuario hace UNA acción explícita (elige letra, escribe, selecciona chip) → revela resultados.
3. Existe siempre un opt-in para "ver todo" (chip "Todos"), pero es explícito — no el default.

En código:
```tsx
const mostrarHint = !filtroActivo && !busqueda;
return mostrarHint ? <Hint /> : <Lista items={filtrados} />;
```

Señal de alerta: si tu componente tiene un `useMemo` que itera sobre 500+ ítems en el render inicial sin ningún guard, probablemente necesita un hint state.

**¿Específico de un stack?** No. Aplica a React, Vue, Svelte, cualquier SPA con listas largas. En mobile-first es especialmente crítico: el hardware es más limitado y el scroll touch es más costoso que el scroll con rueda.
