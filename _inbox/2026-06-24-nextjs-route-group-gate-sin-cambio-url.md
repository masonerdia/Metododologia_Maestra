---
tipo: patron
titulo: Next.js route group para gate de autenticación/rol sin cambiar URL
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: Adaptadores/react-nextjs
---

**Qué pasó / contexto:**
Dos rutas de Denti (`/cobranza`, `/cuentas`) necesitaban quedar gated a `rol === 'duena'`, igual que `/finanzas`, `/gastos` y `/facturación`. La app ya tenía un route group `(admin)/` con un `layout.tsx` que impone el gate de rol + PIN. Solo faltaba mover las rutas a ese grupo.

**Causa raíz / por qué importa:**
Los route groups de Next.js (`(nombre)/`) son carpetas que agrupan rutas para aplicar un layout compartido sin alterar la URL pública. Mover `(app)/cobranza/` a `(app)/(admin)/cobranza/` hace que la URL permanezca `/cobranza` pero ahora hereda el layout `(admin)/layout.tsx` — con todo su gate de autenticación/rol. No hay que duplicar lógica de redirect en cada page.tsx.

Este patrón es la forma idiomática de Next.js para "múltiples niveles de auth" sin duplicar guards:
- `(app)/layout.tsx` → requiere sesión activa (login guard)
- `(app)/(admin)/layout.tsx` → requiere además `rol === 'duena'` + PIN
- `(app)/(app)/layout.tsx` → (hipotético) podría requerir "plan premium" etc.

**Cómo aplicarlo / evitarlo:**

```
src/app/
  (app)/
    layout.tsx          ← gate: sesión activa
    dashboard/          ← accesible a todos (duena + asistente)
    agenda/
    pacientes/
    (admin)/
      layout.tsx        ← gate: rol='duena' + PIN
      finanzas/         ← URL: /finanzas
      gastos/           ← URL: /gastos
      cobranza/         ← URL: /cobranza (movido aquí sin cambiar URL)
```

Para añadir una ruta al gate: `mv src/app/(app)/nueva-ruta/ src/app/(app)/(admin)/nueva-ruta/`

**Gotcha:** si algún Client Component importa directamente desde el path antiguo (ej. `from '@/app/(app)/cobranza/actions'`), el import se rompe y `tsc` lo detecta. Hay que corregir el path al nuevo destino `(admin)/cobranza/actions`. El build sirve para descubrirlos si se olvidó hacer `grep`.

**¿Específico de un stack?** Sí — Next.js App Router (v13+). El equivalente en Pages Router o Remix requiere wrappers de layout manuales.
