---
tipo: patron
titulo: CSV para Excel — prefijo UTF-8 BOM evita mojibake en caracteres especiales
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Al exportar un CSV desde Next.js con caracteres especiales (tildes, ñ, nombres en español), Excel en Windows abría el archivo con codificación Windows-1252 y mostraba caracteres corruptos aunque el archivo fuera UTF-8 válido.

**Causa raíz / por qué importa:** Excel no detecta automáticamente UTF-8 a menos que el archivo comience con el BOM (Byte Order Mark: `﻿` / `EF BB BF`). Sin él asume la codificación del sistema operativo, que en Windows es CP-1252. El CSV es técnicamente correcto pero ilegible para el usuario final.

**Cómo aplicarlo / evitarlo:** Anteponer `'﻿'` al contenido del CSV antes de devolverlo:
```ts
const bom = '﻿';
return new Response(bom + csvBody, {
  headers: {
    'Content-Type': 'text/csv; charset=utf-8',
    'Content-Disposition': `attachment; filename="${slug}.csv"`,
  },
});
```
También: usar `csvField(v)` que envuelva el valor en comillas dobles y duplique las comillas internas (`"` → `""`), nunca confiar en que el valor no tenga comas ni saltos de línea.

**¿Específico de un stack?** No — aplica a cualquier endpoint que genere CSV descargable.
