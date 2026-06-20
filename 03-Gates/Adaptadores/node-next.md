# Adaptador — Node / Next.js [TRANSPORTABLE]

- **Build de producción (gate CI):** `npm ci && npm run build` (p. ej. `next build`). NO basta `tsc --noEmit`: el build de prod atrapa reglas que tsc no (p. ej. exportar no-async en archivos `'use server'`).
- **Smoke test:** Playwright headless contra el build (`next start`): login → 2-3 rutas → assert sin errores de consola y que un clic navega (hidratación).
- **Migraciones:** runner del ORM (Prisma/Drizzle) o SQL versionado con tabla de control; aplicar solo pendientes.
- **Staging:** misma imagen Docker de prod (`output: 'standalone'`), mismos headers, datos sanitizados.
- **Gotchas conocidos:** `'use server'` solo exporta funciones async; service worker puede servir shell viejo tras deploy (versionado de caché + skipWaiting/clientsClaim); no sourcear `.env` con valores sin comillas.

## Un tsconfig por contexto de ejecución
Si el repo mezcla app web (TS browser/Edge, estricto) con scripts Node que usan addons nativos (p. ej. node-firebird), el `tsc` de la app falla al analizar esos scripts (tipos Node vs browser incompatibles). Excluye esos scripts del tsconfig web:
```json
// tsconfig.json de la app
{ "exclude": ["node_modules", "scripts/etl/**"] }
```
Si necesitan type-check propio, un `tsconfig.scripts.json` aparte con su target/lib de Node. Regla: **un tsconfig por contexto de ejecución, no uno por repo.**
