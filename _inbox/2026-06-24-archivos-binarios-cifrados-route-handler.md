# Ficha de lección   [TRANSPORTABLE — formato de salida del CURADOR]

---
tipo: patron
titulo: Servir archivos binarios cifrados (AES-256-GCM) vía route handler Next.js con RLS
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Se necesitaba servir el logo de cada clínica (almacenado cifrado en filesystem como `.enc`) a través de una URL pública de la app (`/api/clinica/logo`). La imagen debía ser accesible solo al usuario autenticado de esa clínica.

**Causa raíz / por qué importa:** Los archivos sensibles o privados no deben estar en `public/` ni servirse directamente por el webserver. Pasarlos por un route handler autenticado garantiza que el RLS de la aplicación controle el acceso, no las reglas de red.

**Cómo aplicarlo / evitarlo:**

```typescript
export const runtime = 'nodejs'; // necesario para fs/crypto

export async function GET() {
  try {
    const sesion = await getSesionClinica(); // throws si no autenticado
    const rows = await withClinica(sesion.clinicaId, tx =>
      tx`SELECT file_path FROM tabla WHERE id = ${sesion.clinicaId} LIMIT 1`
    );
    const filePath = rows[0]?.file_path;
    if (!filePath) return new NextResponse(null, { status: 404 });

    const buffer = await leerAdjunto(filePath); // desencripta AES-256-GCM

    // Inferir Content-Type por extensión pre-.enc (no del request)
    const ext = filePath.split('.').slice(-2, -1)[0] ?? '';
    const contentType = ext === 'png' ? 'image/png'
      : ext === 'webp' ? 'image/webp' : 'image/jpeg';
    // Nunca SVG: image/svg+xml puede contener scripts XSS

    return new NextResponse(new Uint8Array(buffer), {
      headers: {
        'Content-Type': contentType,
        'Cache-Control': 'private, max-age=3600',
        'X-Content-Type-Options': 'nosniff',
      },
    });
  } catch {
    return new NextResponse(null, { status: 404 }); // no filtrar info
  }
}
```

Reglas clave:
- `runtime = 'nodejs'` — Edge runtime no tiene `fs` ni `crypto`.
- Sin SVG en la allowlist — SVG puede contener `<script>` → XSS.
- El `file_path` viene de BD (bajo RLS), no del request del cliente → sin path traversal.
- `Cache-Control: private` — no cacheable en CDN compartida.
- `try/catch` amplio → 404 genérico, sin fuga de información del filesystem.

**¿Específico de un stack?** Sí — Next.js App Router (route handlers). El principio es agnóstico; la implementación usa Next.js Response y `runtime = 'nodejs'`.
