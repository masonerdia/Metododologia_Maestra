---
tipo: patron
titulo: Excluir scripts con deps nativas del tsconfig de la app para evitar conflictos de tipos
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Un proyecto con una app web Next.js (TypeScript estricto) y scripts ETL en el mismo repositorio usaba un addon nativo de Node.js (node-firebird) incompatible con los tipos de la app. El compilador de TypeScript de la app analizaba los scripts ETL y fallaba por conflictos de tipos de módulos Node vs. browser.

**Causa raíz / por qué importa:** Un único `tsconfig.json` que abarca todo el proyecto intenta unificar contextos de ejecución (browser/Edge + Node.js nativo) que tienen tipos incompatibles. La consecuencia es que `npx tsc --noEmit` —la comprobación de calidad— falla por código que no pertenece al dominio de la app.

**Cómo aplicarlo / evitarlo:** Agregar los paths de los scripts con dependencias incompatibles al campo `exclude` del `tsconfig.json` principal de la app:

```json
// tsconfig.json de la app
{
  "exclude": ["node_modules", "scripts/etl/**"]
}
```

Si los scripts necesitan type-checking propio, crear un `tsconfig.scripts.json` separado con el `target` y `lib` adecuados para Node.js. La regla general: **un tsconfig por contexto de ejecución**, no uno por repositorio.

**¿Específico de un stack?** Sí (TypeScript), pero el principio de separar contextos de compilación aplica a cualquier lenguaje con sistemas de tipos configurables (Babel presets, tsc projects, webpack targets).
