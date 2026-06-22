---
tipo: patron
titulo: Búsqueda insensible a acentos y orden de palabras en SQL sobre datos heredados (ETL)
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Un asistente IA respondía "no encontré" para pacientes que sí existían. Los datos se importaron desde un sistema legacy (eDentistry) que almacena nombres como "APELLIDO NOMBRE" en mayúsculas. La búsqueda usaba `nombre ILIKE '%texto%'`, que es sensible al orden de las palabras y a los acentos — "Mateo Pérez" nunca casaba con "PEREZ MATEO".

**Causa raíz / por qué importa:** Hay dos clases de discrepancia entre datos legacy y búsqueda de usuario:

1. **Formato de orden:** Los sistemas heredados suelen almacenar nombres en formato "APELLIDO NOMBRE" (convención administrativa), mientras que los usuarios escriben "Nombre Apellido" naturalmente.
2. **Normalización de texto:** Los sistemas legacy pueden tener datos en mayúsculas sin acentos, pero el usuario escribe con acentos y minúsculas.

Un `ILIKE '%substring%'` falla ambas clases porque exige que el texto del usuario sea un substring contiguo del campo — roto si el orden difiere o si los acentos no están.

**Cómo aplicarlo / evitarlo:**

**Patrón: tokenización + translate() en SQL (sin extensión unaccent)**

Paso 1 — Normalizar el input del usuario en JS/TS:
```typescript
function normTokens(ref: string): string[] {
  return (ref || '').normalize('NFD')
    .replace(/[̀-ͯ]/g, '')  // strip combining diacritics
    .toLowerCase().trim()
    .split(/\s+/).filter(Boolean).slice(0, 5);  // máx 5 tokens
}
```

Paso 2 — En SQL, un `LIKE '%token%'` por token (AND), normalizando la columna:
```sql
translate(lower(nombre), 'áéíóúüñ', 'aeiouun') LIKE '%token1%'
AND translate(lower(nombre), 'áéíóúüñ', 'aeiouun') LIKE '%token2%'
```

Con postgres.js se construye dinámicamente con fragments:
```typescript
const partes = tokens.map(
  t => tx`translate(lower(col),'áéíóúüñ','aeiouun') LIKE ${'%' + t + '%'}`
);
const cond = partes.reduce((a, b) => tx`${a} AND ${b}`);
// Luego: tx`SELECT ... WHERE ... AND ${cond}`
```

**Propiedades del patrón:**
- Orden-independiente: "Mateo Pérez" encuentra "PEREZ MATEO".
- Accent-insensitive: "Perez" encuentra "PÉREZ".
- Sin extensión PostgreSQL: `translate()` es built-in; no requiere `unaccent`.
- Parameterizado: los tokens van como `$1`, `$2`… sin riesgo de inyección SQL.
- `slice(0,5)`: limita el número de tokens para que el query no crezca sin control.

**Cuándo aplicar este patrón:**
- Cualquier búsqueda de texto libre sobre datos migrados de sistemas legacy.
- Cuando el usuario puede escribir el texto en un orden distinto al almacenado (nombres, apellidos, razones sociales, etc.).
- Cuando los datos originales tienen acentos variables o fueron almacenados en mayúsculas.

**Señal de alerta:** Si un usuario reporta que "no se encuentra" algo que sí existe, comparar primero el valor exacto en BD con lo que el usuario escribe — discrepancias de orden o acentos son la causa más frecuente en datos migrados.

**¿Específico de un stack?** El patrón JS (NFD) es agnóstico. La parte SQL usa `translate()` de PostgreSQL; para MySQL/SQLite usar alternativas (`COLLATE utf8_general_ci` o funciones equivalentes). Los fragments de postgres.js son específicos de esa librería; adaptar a query builder propio si se usa otro.
