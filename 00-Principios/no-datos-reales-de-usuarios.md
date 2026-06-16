# Principio · No datos reales de usuarios en artefactos

**Regla:** jamás datos reales de personas (nombres, teléfonos, IDs fiscales, datos de salud) en código, seeds, tests, fixtures, logs, commits, screenshots, documentación ni en respuestas de agentes. Seeds y demos siempre con datos ficticios.

**Por qué:** privacidad/legal (en salud, NOM/LFPDPPP o equivalente; en general, protección de datos). Un dato real filtrado en un repo o log es difícil de borrar y es un riesgo permanente.

**Cómo aplicarlo:** datos sintéticos en seeds; logs con conteos e IDs, no PII; las migraciones reales corren en entorno seguro, no en el repo. Verificable en [[auditoria-de-seguridad]].

Relacionado: [[integridad-de-dinero-y-datos]], [[revision-de-seguridad]].
