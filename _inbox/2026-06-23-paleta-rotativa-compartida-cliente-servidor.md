---
title: Paleta rotativa compartida entre cliente y servidor para asignación automática
date: 2026-06-23
source: Denti HOTFIX-0024
tags: [ux, backend, saas, color, consistencia, arquitectura]
---

## Lección

Cuando se asigna automáticamente un atributo visual (color, ícono, avatar) a entidades creadas desde distintos puntos de entrada (UI manual y asistente de voz/chat), la lógica de asignación debe vivir en **un único lugar compartido** accesible desde ambos contextos.

Patrón: definir el array/catálogo de opciones en un módulo importable por cliente y servidor, y la función de asignación como `catálogo[count % catálogo.length]` donde `count` es el número de entidades existentes en la misma clínica/tenant.

## Por qué importa

Si la UI asigna colores con una lógica y el backend asigna con otra, las entidades creadas por cada canal tendrán distribuciones de color distintas. En el peor caso, dos entidades del mismo tenant reciben el mismo color porque cada canal mantiene su propio contador. El usuario ve inconsistencia que erosiona la confianza en el producto.

Además, cualquier cambio en la paleta (agregar un color, reordenar) debe actualizarse en un solo lugar, no en dos.

## Cómo aplicar

1. Crear un archivo compartido `lib/paleta.ts` (o equivalente fuera de `app/`) con:
   ```typescript
   export const COLORES_PALETA = ['#E57373', '#64B5F6', /* ... */] as const;
   export type ColorPaleta = (typeof COLORES_PALETA)[number];
   
   export function asignarColorAuto(countExistentes: number): ColorPaleta {
     return COLORES_PALETA[countExistentes % COLORES_PALETA.length];
   }
   ```
2. Importar `asignarColorAuto` tanto en el server action de UI como en la función del asistente.
3. La query para `count` debe filtrar por el mismo scope de tenant (`clinica_id`, `org_id`, etc.) para que el contador sea coherente con lo que ve cada cliente.
4. En la UI de creación manual, usar el mismo `COLORES_PALETA` para el selector de color — el usuario ve exactamente los mismos colores que el sistema asignaría automáticamente.

**Variante:** si el orden de asignación no importa y solo importa evitar duplicados, usar `find` sobre la paleta para el primer color no usado. El `mod` es más simple y suficiente para catálogos pequeños.
