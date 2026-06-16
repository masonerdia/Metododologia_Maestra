# Proyecto · Denti (referencia "100% aplicado")

CRM dental SaaS. Es el proyecto del que se **destiló** esta metodología y donde cada casilla está llena — úsalo como ejemplo concreto de cómo se ve el método aplicado.

- **Su metodología vive en su propio repo** (no se copia aquí): `CLAUDE.md`, `AGENTS.md`, `CHECKPOINTS.md`, `docs/`, `SPEC-*`, `progress/history`, `feature_list.json`, `.claude/agents/`.
- En ese repo, el archivo **`MAPA-Metodologia-Denti.md`** mapea sus archivos reales contra este mismo esqueleto (ábrelo abriendo la carpeta de Denti como bóveda).

**Estado de adopción (referencia):**
- Núcleo: ✅ pipeline de roles, preview-antes-de-construir, mobile+desktop, principios (centavos, soft-delete, multi-tenant RLS, no PII), historial, consolidación de notas.
- Gates: ✅ build de producción (añadido al cierre), backups offsite; ⚠️ pendientes: staging idéntico, smoke test en CI, runner de migraciones con ledger, restore drill, revisión de seguridad. **Estos son el delta vivo de Denti** y un buen ejemplo de que aun el proyecto de referencia tiene frontera por cerrar.

> Lección meta de Denti: casi todos los incidentes vivieron en la **frontera con producción** (build de prod vs type-check, contenedor real, service worker, .env frágil). De ahí salieron varios gates de `03-Gates/`.
