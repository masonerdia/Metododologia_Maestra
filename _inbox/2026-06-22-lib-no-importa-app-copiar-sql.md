---
tipo: patron
titulo: "lib no importa app: copiar la SQL con param explícito en lugar de importar la función del caller"
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: Adaptadores/NextJS
---

**Qué pasó / contexto:** En un proyecto Next.js App Router con arquitectura en capas (`lib/` ↔ `app/`), una función en `lib/asistente/ejecutar.ts` necesitaba los mismos datos que una función en `app/(app)/pacientes/actions.ts` obtenía llamando a `getSesionClinica()`. La tentación fue importar la función de `app/` desde `lib/`.

**Causa raíz / por qué importa:** Importar `app/` desde `lib/` invierte la jerarquía de dependencias: `lib/` deja de ser autónoma y el módulo de la app ya no puede ser reemplazado o testeado en aislamiento. En Next.js App Router esto además puede romper el build porque `getSesionClinica()` usa `auth()` (solo disponible en Server Components/Actions, no en módulos genéricos).

**Cómo aplicarlo / evitarlo:**
- **Regla:** `lib/` recibe todos sus datos como parámetros de función, nunca los extrae de la sesión ni importa de `app/`.
- **Patrón concreto:** si la capa de `app/` ya tiene la SQL en una función `getXxx(clinicaId)`, copiar esa SQL en la función de `lib/` con `clinicaId` como primer parámetro. Es repetición deliberada, no un anti-patrón: la repetición compra independencia de capas.
- **Señal de alarma:** si `lib/` necesita importar `getSesionClinica`, `auth()`, `cookies()`, `headers()` o cualquier Server Component API, la arquitectura está invertida.

**¿Específico de un stack?** Sí — Next.js App Router (`app/` vs `lib/`). Generalizable a cualquier framework con capas explícitas (Django views/services, Express controllers/services).
