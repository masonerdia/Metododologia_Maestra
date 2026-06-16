# Gate · Restore drill (no solo backup)

**Qué:** probar periódicamente que un backup **se puede restaurar** — bajar el último respaldo y restaurarlo en un entorno desechable.

**Por qué:** un backup que nunca restauraste no es un backup. Las fallas (formato, claves de cifrado faltantes, dumps corruptos) solo se descubren al intentar restaurar — idealmente no durante una emergencia real.

**Cómo (principio):** offsite real (no solo en el mismo servidor); las claves de cifrado se respaldan **aparte** del dato; un drill agendado que documenta el resultado.

Relacionado: [[integridad-de-dinero-y-datos]], [[revision-de-seguridad]].
