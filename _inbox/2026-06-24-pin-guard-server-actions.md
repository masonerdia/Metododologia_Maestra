# Ficha de lección   [TRANSPORTABLE — formato de salida del CURADOR]

---
tipo: patron
titulo: Guard reutilizable de PIN para server actions destructivas
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Se necesitaba proteger soft-deletes (citas, pagos, pacientes) en un SaaS con solo la dueña habilitada para hacerlos. El viejo `window.confirm()` no era auditable ni seguro. Se implementó un guard `requierePin()` que verifica el PIN hasheado con argon2 antes de ejecutar cualquier mutación destructiva.

**Causa raíz / por qué importa:** Las operaciones irreversibles necesitan una segunda capa de autenticación más allá de la sesión activa. Un usuario que deja la pantalla desbloqueada no debería poder borrar registros con un clic accidental. La auditoría de intentos fallidos con lockout previene ataques de fuerza bruta internos.

**Cómo aplicarlo / evitarlo:**

1. Crear `lib/requierePin.ts` — función async que recibe `pin: string | null`, verifica contra `argon2`, gestiona contador de intentos y lockout en BD. Retorna `{ ok: true } | { error: string; lockout?: boolean }`.
2. En el server action destructivo: `const pinCheck = await requierePin(formData.get('pin_confirmacion')); if ('error' in pinCheck) return { error: pinCheck.error };`
3. Que el server action retorne `Promise<{ error: string } | void>` en lugar de `Promise<void>`.
4. Client component `PinModal`: `type="password" inputMode="numeric"`, autofocus al abrir, Enter confirma, Escape cancela, muestra el error recibido y limpia el input.
5. Graceful degradation: si el usuario no tiene PIN configurado, `requierePin` retorna `{ ok: true }` sin bloquear (permite onboarding gradual).

**¿Específico de un stack?** Sí — Next.js App Router (server actions). El patrón `requierePin` es agnóstico; el `PinModal` client component es específico de React.
