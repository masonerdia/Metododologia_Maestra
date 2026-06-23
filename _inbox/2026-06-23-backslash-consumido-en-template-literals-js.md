---
tipo: bug
titulo: Backslash consumido en template literals JS — regex enviado sin la secuencia de escape
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** La detección de duplicados por celular no funcionaba — pacientes con `'55-500-02222'` y `'5550002222'` no se agrupaban. El SQL era correcto: verificado directamente en psql, `regexp_replace('55-500-02222', '\D', '', 'g')` = `'5550002222'`. Pero via postgres.js template literal, la función recibía `'D'` como patrón de regex en lugar de `'\D'`.

**Causa raíz / por qué importa:** En JavaScript, `\D` dentro de un template literal es un `NonEscapeCharacter` — el intérprete consume el backslash y entrega solo `D`. La cadena SQL enviada a PostgreSQL contenía `regexp_replace(celular, 'D', '', 'g')` en lugar del `'\D'` esperado. El bug es **silencioso**: tsc lo ignora (es JS válido), los tests pasan si los datos de prueba no contienen el carácter que el regex erróneo capturaría (ningún celular de test tenía la letra `D`). La discrepancia solo aparece al comparar la salida de la función con la del psql directo.

**Cómo aplicarlo / evitarlo:**

En cualquier template literal de tagged-template library (postgres.js, `gql`, styled-components, etc.):

1. **Regla de oro:** si el SQL literal necesita un backslash, escribir `\\` en JS para que PostgreSQL reciba uno solo: `'\\D'`, `'\\s+'`, `'\\w+'`.
2. **Alternativa más legible:** usar clases POSIX explícitas sin backslash: `'[^0-9]'` en lugar de `'\D'`, `'[[:space:]]+'` en lugar de `'\s+'`.
3. **Verificación:** cuando un regex SQL parece correcto en psql pero falla en la aplicación, comparar el SQL real enviado (activar query logging o agregar `console.log` temporal del fragmento). Si el resultado de psql difiere, buscar backslashes en el template literal JS.
4. **Diagnóstico de "el bug que pasa los tests":** si un regex falla silenciosamente en casos reales pero no en tests, revisar si los datos de test contienen los caracteres que el regex incorrecto sí capturaría — un patrón `'D'` no elimina hifens pero tampoco rompe cadenas sin la letra D.

**¿Específico de un stack?** Parcialmente: el escape `\\` es idioma JavaScript universal. La aplicación concreta a postgres.js template literals es de ese stack, pero la regla del backslash en template literals aplica a cualquier tagged template en JS/TS.
