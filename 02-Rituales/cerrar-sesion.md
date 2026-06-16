# Ritual · Cerrar sesión

Ejecuta el [[CUSTODIO]], re-verifica el [[AUDITOR-CIERRE]] (lista V1..Vn) y, al final, cosecha el [[CURADOR]]. Sin veredicto de cierre, la sesión no terminó.

## Fases
1. **CUSTODIO** — inventario de cambios · sync de docs (estado, historial, índice, errores conocidos) · verificación técnica (**build de producción**, no solo type-check) · filtro de seguridad (sin secretos ni PII) · commit + tag si cierra fase · **push del repo del proyecto** · remoto==local.
2. **AUDITOR-CIERRE** — re-verifica con checklist V1..Vn; veredicto en el historial de auditorías.
3. **CURADOR** (solo tras cierre completo) — destila las **lecciones genéricas y reutilizables** de la sesión y deja una [[ficha-de-leccion]] por cada una en el **`_inbox/` de la maestra**. NO promueve a lo canónico; 0 fichas es válido. Lo específico del proyecto va a la memoria del proyecto, no a la maestra.
4. **Versionado de la maestra** — `git add _inbox && commit && push` de las propuestas (si hay credenciales; si no, dejar el commit y mostrar el comando). La **promoción** de `_inbox/` → canónico la hace una persona en Obsidian.
5. **Reporte** — qué cerró · qué quedó en vuelo · lecciones propuestas (N) · siguiente paso · recordatorio de revisar `_inbox` en Obsidian.

## Cómo instanciarlo en un proyecto
- El comando concreto vive en el repo del proyecto (ej. `.claude/commands/cierre-sesion.md`) con la ruta a la bóveda maestra como configuración.
- El agente [[CURADOR]] necesita acceso a la sesión + a la carpeta de la maestra (ambas locales en el equipo).

Relacionado: [[done-es-desplegado-y-verificado]], [[history-append-only]], [[documentar-las-lecciones]], [[CURADOR]].
