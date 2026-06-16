# AGENTS — pipeline del proyecto   [TRANSPORTABLE]

Pipeline: LEADER → IMPLEMENTER → AUDITORES → GUARDIAN-UX (si toca UI) → REVIEWER.
Cierre: CUSTODIO + AUDITOR-CIERRE.

- LEADER: brief + criterios; no codifica.
- IMPLEMENTER: implementa el brief; lee antes de editar; no amplía alcance.
- AUDITORES: funcional · mobile · desktop · UI · seguridad/integral.
- GUARDIAN-UX: visto bueno de experiencia y FLUJO entre vistas; veta si no se puede llegar/salir.
- REVIEWER: gate final; build de producción verde + tests; no modifica.
- CUSTODIO / AUDITOR-CIERRE: cierre verificado.

Reglas: máx 1 in_progress; visto bueno UX adicional al funcional; especialista invitado hereda el pipeline.
Tiering: en bajo riesgo el pipeline puede colapsarse a 1 rol + checklist.
