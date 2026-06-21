---
tipo: bug
titulo: String.includes("") siempre true — filtro de búsqueda nunca filtra
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** El buscador de `/pacientes` no filtraba la lista al escribir texto. La causa: la lógica de filtro derivaba un término de teléfono con `q.replace(/\D/g,'')`. Cuando el usuario escribía solo texto (ej. "Paola"), el término de teléfono resultante era `""`. La condición era `celular.replace(/\D/g,'').includes("")`, que en JavaScript es **siempre `true`** para cualquier string (incluido `""`). El OR cortocircuitaba con `true` para todos los pacientes, y la lista nunca se reducía.

**Causa raíz / por qué importa:** `"cualquiercosa".includes("")` devuelve `true` en JavaScript (y en la mayoría de lenguajes que implementan la semántica de subcadena vacía). Es una trampa silenciosa: el código compila, no lanza errores, la UI parece funcionar, pero el filtro nunca actúa. El bug aparece cada vez que:
1. Se deriva un término de búsqueda del input del usuario aplicando una transformación (strip de no-dígitos, normalización, etc.).
2. Esa transformación puede producir una cadena vacía.
3. Se usa ese término derivado en `.includes()` sin verificar si está vacío.

**Cómo aplicarlo / evitarlo:**
- **Regla:** antes de aplicar `.includes(derived)` en un filtro, verificar `derived.length > 0`. Si está vacío, ese criterio no aporta información → omitirlo (o considerar todos como coincidencia, según la semántica deseada).
- Patrón correcto:
  ```ts
  const termDigits = q.replace(/\D/g, '');
  const matchTel = termDigits.length > 0 && celular.replace(/\D/g, '').includes(termDigits);
  return matchNombre || matchTel;
  // ✗ Incorrecto:
  // return matchNombre || celular.replace(/\D/g,'').includes(q.replace(/\D/g,''));
  ```
- El mismo riesgo aplica a otros derivados: `normalizar(q.trim())` puede ser `""` si `q` son solo espacios — de ahí el guard `if (!termNorm) return true` que precede el filtro.
- En código de revisión: cada vez que se vea `.includes(variable)` en un filtro, preguntar: "¿puede `variable` ser `""`? ¿qué devuelve entonces?".

**¿Específico de un stack?** No — aplica a cualquier lenguaje/framework donde `.includes("")` (o equivalente: `startsWith("")`, `indexOf("") !== -1`, `LIKE '%'` en SQL) devuelve true para cadena vacía. La regla del guard es universal.
