# Ficha de lección   [TRANSPORTABLE — formato de salida del CURADOR]

---
tipo: patron
titulo: Log append-only best-effort en rutas de descarga — no bloquear la entrega de valor
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 03-Gates
---

**Qué pasó / contexto:** El route handler `GET /api/sires/exportar` genera y descarga archivos GIIS. También registra cada exportación en la tabla `giis_exportacion` (para auditoría). Si el INSERT en el log falla (tabla no aplicada en dev, error transitorio), el handler no debe impedir la descarga.

**Causa raíz / por qué importa:** El usuario descargó el archivo para cumplir con una obligación regulatoria — es el valor primario. El log es auditoría secundaria. Si el try/catch del log lanza y el handler devuelve 500, el usuario perdió la descarga por algo irrelevante para él. En dev, la migración 046 puede no estar aplicada; sin best-effort, ninguna descarga funcionaría en dev.

**Cómo aplicarlo / evitarlo:** Patron: `try { await registrarLog(...) } catch { /* best-effort */ }` envuelve el INSERT del log. El valor primario (descarga, envío, notificación) siempre ocurre. El log puede perderse ocasionalmente pero nunca bloquea. Documentar en comentario que es best-effort y por qué. Aplicar solo cuando el log es auditoría secundaria — si el log ES el valor primario (transacción financiera, consentimiento firmado), debe lanzar.

**¿Específico de un stack?** No — patrón universal. La sintaxis es JavaScript async/await pero el concepto aplica a cualquier sistema.
