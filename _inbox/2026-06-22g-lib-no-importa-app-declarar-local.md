---
tipo: patron
titulo: lib no importa app — duplicar pequeñas constantes localmente en lugar de crear ciclo de dependencias
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** En Denti, `ejecutar.ts` vive en `src/lib/asistente/` (capa de librería). Necesitaba la constante `TRANSICIONES` definida en `src/app/(app)/agenda/actions.ts` (capa de app/rutas). La opción "directa" era importar actions.ts desde ejecutar.ts.

**Causa raíz / por qué importa:** En Next.js (y en arquitectura limpia en general), `lib/` contiene lógica pura reutilizable que no debe depender de la capa de UI/routing. Si `lib/` importa de `app/`, se invierte la dirección de dependencias: ahora `lib/` asume que existe una estructura de rutas específica, y un refactor de rutas puede romper la librería. En Next.js esto también puede causar errores de bundle (módulos de servidor en contextos de cliente).

**Cómo aplicarlo / evitarlo:**

Cuando una constante pequeña (`TRANSICIONES`, un enum, una regex de validación) existe en `app/` pero la necesitas en `lib/`:

1. **Si la constante es del dominio (no de la UI):** Declárala localmente en `lib/`, con un comentario que diga de dónde viene el espejo:
   ```ts
   // Máquina de estados — espejo de agenda/actions.ts (sin importar app desde lib).
   const TRANSICIONES: Record<string, string[]> = { ... }
   ```

2. **Si la constante se usa en muchos sitios:** Moverla a `lib/` o a un archivo `lib/dominio/tipos.ts` compartido; `app/` la importa desde ahí (dirección correcta).

3. **Nunca:** `import { constante } from '@/app/(app)/módulo/actions'` en ningún archivo de `lib/`.

Regla de oro: la dirección de dependencias es siempre `app → lib`, nunca `lib → app`.

**¿Específico de un stack?** No en el concepto (clean architecture / dependency inversion). Sí en el síntoma en Next.js (route handlers, server actions y `app/` son contextos de servidor con imports especiales). Aplica también en React + Express, Django, Rails, etc. — las capas de infraestructura/routing no deben contaminar el dominio.
