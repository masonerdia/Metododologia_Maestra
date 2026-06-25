# Ficha de lección   [TRANSPORTABLE — formato de salida del CURADOR]

---
tipo: patron
titulo: Puerto-Adaptador-Factory como unidad mínima de exportación regulatoria
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** DENTI-0055 implementó la exportación al sistema GIIS (gobierno mexicano). En lugar de codificar la lógica directamente en el route handler, se creó: (1) un puerto con interfaces TypeScript puras (`giis-exporter.ts`), (2) un adaptador versioned (`GiisExporterV1`) que implementa el puerto, (3) una factory singleton (`getGiisExporter()`). El route handler solo conoce la interfaz del puerto.

**Causa raíz / por qué importa:** Las integraciones regulatorias cambian de formato (B015 → B016 → futura versión). Con el patrón Puerto-Adaptador, cambiar de versión = crear `GiisExporterV2` e intercambiar en la factory. El route handler, los tests y el resto de la app no cambian. Sin este patrón, cada cambio regulatorio requiere tocar N archivos.

**Cómo aplicarlo / evitarlo:** Para cualquier exportación hacia sistemas externos (gubernamentales, contables, de salud): (1) Define un puerto en `lib/ports/` con tipos de entrada/salida; (2) Crea el adaptador en `lib/adapters/<sistema>/`; (3) Expón solo una factory en `lib/<sistema>.ts`; (4) El route handler y la UI solo importan de la factory. Tests unitarios prueban el adaptador directamente; tests de integración prueban el route handler.

**¿Específico de un stack?** No — patrón agnóstico. La implementación con TypeScript interfaces + singleton es idiomática de Node.js/TS pero el concepto es universal.
