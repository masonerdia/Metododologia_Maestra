# Ficha de lección   [TRANSPORTABLE — formato de salida del CURADOR]

---
tipo: patron
titulo: UI "por excepción" en formularios clínicos de alta frecuencia
proyecto_origen: Denti
fecha: 2026-06-27
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** La exploración clínica oral en Denti requería que la doctora llenara 9 regiones anatómicas en cada visita. Con textarea por región, el formulario era lento y abandonado. Se rediseñó como "por excepción": todas las regiones se preseleccionan como "Normal" (verde), y el médico solo toca lo que difiere del estado sano.

**Causa raíz / por qué importa:** En flujos clínicos de alta frecuencia, el estado "normal" es estadísticamente el más común (≥80% de casos en una visita de rutina). Un formulario que exige marcar "normal" explícitamente desperdicia tiempo y genera abandono. La forma en que la UI framing cambia el esfuerzo del usuario: escribir todo vs. marcar solo lo raro.

**Cómo aplicarlo / evitarlo:**

Tres ingredientes necesarios:

1. **Catálogo configurable por tenant con flag `es_normal`:**
```sql
CREATE TABLE exploracion_opcion (
  id         UUID PRIMARY KEY,
  clinica_id UUID NOT NULL,  -- tenant
  region     TEXT NOT NULL,  -- agrupador visual
  etiqueta   TEXT NOT NULL,
  es_normal  BOOLEAN NOT NULL DEFAULT false,  -- ← preselección
  orden      INT NOT NULL DEFAULT 0,
  deleted_at TIMESTAMPTZ NULL
);
```
El flag `es_normal` lo configura el administrador por especialidad — odontología tiene "Sin alteración"; oftalmología tendría "Visión normal".

2. **Inicialización de estado en frontend — preseleccionar normal:**
```typescript
function buildDefaultHallazgos(
  opciones: Record<string, OpcionExploracion[]>
): Record<string, HallazgoItem> {
  const result: Record<string, HallazgoItem> = {};
  for (const [region, opts] of Object.entries(opciones)) {
    const normal = opts.find((o) => o.es_normal) ?? opts[0];
    if (normal) {
      result[region] = {
        region,
        opcion_id: normal.id,
        opcion_etiqueta: normal.etiqueta,
        es_hallazgo: false,
      };
    }
  }
  return result;
}
```

3. **Chip visual que comunica el estado sin texto:**
- Verde brillante (`#f0fdf4` / borde `#86efac`) = Normal/Sano. El ojo lo ignora.
- Ámbar (`#fef3c7` / borde `#fcd34d`) = Hallazgo. El ojo lo captura.
- Sin selección (gris bajo) = chip disponible pero no activo.

Selección única por región (no multi-select) para evitar ambigüedad clínica.

**Cuándo aplicar este patrón:**
- Formularios donde el 70%+ de los campos tendrán valor "Normal/OK/Sin cambios".
- Flujos de alta frecuencia (mismas secciones en cada visita).
- Usuarios en contextos de alta carga cognitiva (médicos entre pacientes).

**Cuándo NO aplicar:**
- Admisiones de urgencia — el estado "normal" no existe como punto de partida.
- Formularios de una sola vez (consentimientos, datos demográficos).
- Cuando el catálogo es tan largo que los chips no caben en pantalla sin scroll.

**Complemento: "Copiar de la última visita":**
Guardar las selecciones en JSONB permite recuperarlas la próxima sesión. Reduce aún más el esfuerzo si el estado del paciente es estable. Patrón: `cargarUltimaExploracion(pacienteId)` → pre-pobla el estado React → médico solo ajusta lo que cambió.

**¿Específico de un stack?** No — el principio es de diseño UX. La implementación con chips + JSONB es React/PostgreSQL, pero el patrón es aplicable a cualquier formulario clínico digital.
