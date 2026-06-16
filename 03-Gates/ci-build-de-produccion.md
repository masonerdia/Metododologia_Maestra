# Gate · Build de PRODUCCIÓN en CI (no solo type-check)

**Qué:** el CI debe correr el **build de producción real** del proyecto, no solo el type-check/linter/unit. Bloquea el merge si falla.

**Por qué:** hay errores que `tsc`/compilador-incremental NO atrapan y solo aparecen en el build de producción (reglas de framework, tree-shaking, restricciones de "server/client", bundling). "Compila en dev" ≠ "buildea para prod". Es la causa #1 de incidentes en la frontera con producción.

**Cómo (principio):** el gate es el **mismo comando que produce el artefacto desplegable**. Ver el comando por stack en `Adaptadores/`.

Relacionado: [[done-es-desplegado-y-verificado]], [[REVIEWER]].
