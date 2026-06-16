# Adaptador — Node / Next.js [TRANSPORTABLE]

- **Build de producción (gate CI):** `npm ci && npm run build` (p. ej. `next build`). NO basta `tsc --noEmit`: el build de prod atrapa reglas que tsc no (p. ej. exportar no-async en archivos `'use server'`).
- **Smoke test:** Playwright headless contra el build (`next start`): login → 2-3 rutas → assert sin errores de consola y que un clic navega (hidratación).
- **Migraciones:** runner del ORM (Prisma/Drizzle) o SQL versionado con tabla de control; aplicar solo pendientes.
- **Staging:** misma imagen Docker de prod (`output: 'standalone'`), mismos headers, datos sanitizados.
- **Gotchas conocidos:** `'use server'` solo exporta funciones async; service worker puede servir shell viejo tras deploy (versionado de caché + skipWaiting/clientsClaim); no sourcear `.env` con valores sin comillas.
