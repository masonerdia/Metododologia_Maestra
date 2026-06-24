---
title: Re-validar conflicto de recurso cuando la entidad asignada aún no existe
date: 2026-06-23
source: Denti HOTFIX-0024
tags: [backend, concurrencia, saas, agenda, validacion]
---

## Lección

Cuando se valida un conflicto de recurso (horario, sala, inventario) y la entidad que lo usaría aún no existe en BD, el filtro por `entidadId` en la consulta de conflicto **no debe aplicarse**. La query de conflicto debe correr sin filtro de entidad para detectar cualquier solapamiento en ese recurso, independientemente de quién lo use.

Ejemplo concreto: al agendar una cita para un doctor nuevo (que se creará al confirmar), buscar conflictos de horario **sin filtrar por `profesional_id`** — si el slot ya está ocupado por cualquier doctor, hay conflicto.

## Por qué importa

El patrón usual de re-validación (`conflicto(clinicaId, inicio, fin, profesionalId)`) asume que el asignado ya tiene un ID. Si se pasa `null` como ID y la query filtra con `AND profesional_id = $n`, el filtro se comporta como `AND profesional_id IS NULL` (o simplemente no filtra y devuelve todos), dependiendo del ORM/driver. Ambos son incorrectos y producen resultados silenciosamente erróneos.

## Cómo aplicar

1. En la función de conflicto, hacer el parámetro de entidad opcional: `conflicto(clinicaId, inicio, fin, entidadId?: string)`.
2. Si `entidadId` es null/undefined, omitir completamente el fragmento `AND entidad_id = $n` de la query — no incluirlo como `NULL`.
3. Esto produce una validación más conservadora (cualquier ocupación del recurso bloquea) que es el comportamiento correcto cuando la entidad es nueva y no tiene historial.
4. Documentar en el comentario de la función: "si entidadId es omitido, valida contra todos los asignados".

```typescript
// Ejemplo de patrón
async function conflictoHorario(
  clinicaId: string,
  inicio: Date,
  fin: Date,
  profesionalId?: string   // omitir para doctor nuevo
): Promise<boolean> {
  const filtroProfesional = profesionalId
    ? sql`AND profesional_id = ${profesionalId}`
    : sql``; // sin filtro = más restrictivo, correcto para entidad nueva
  const rows = await db`
    SELECT 1 FROM citas
    WHERE clinica_id = ${clinicaId}
      AND estado != 'cancelada'
      AND tstzrange(inicio, fin) && tstzrange(${inicio}, ${fin})
      ${filtroProfesional}
    LIMIT 1
  `;
  return rows.length > 0;
}
```
