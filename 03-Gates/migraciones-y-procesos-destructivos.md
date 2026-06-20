# Gate · Migraciones y procesos destructivos (ETL, cutover, batch)

Reglas para procesos puntuales con acceso privilegiado a producción (migraciones, ETL, cutovers, jobs destructivos). Destiladas de Denti (DENTI-0041).

## 1. Runner efímero, separado del compose principal
El proceso de migración NO es un servicio. Empaquétalo como **runner efímero**: un `docker-compose.<proceso>.yml` aparte, `run --rm` (no deja rastro), `depends_on: <origen>: condition: service_healthy`, y comparte la **red externa** del proyecto para alcanzar la BD destino sin exponer puertos. El compose de producción queda limpio.

## 2. Modo seguro por env var (no flags ni constantes)
El comportamiento peligroso (escritura real vs. simulación) se controla con una **env var con default seguro** (`ETL_MODO=TEST|PROD`, default `TEST`; o `DRY_RUN=true`). Observable (`echo $ETL_MODO`), auditable, forzable a seguro en el compose. Nunca una constante hardcodeada que haya que "acordarse de revertir", ni un flag CLI fácil de olvidar.

## 3. Credenciales solo por env del shell del operador
Las credenciales de un proceso con acceso a prod se referencian como `${VAR}` **sin default** en el compose; el operador las exporta en su shell antes de ejecutar. NUNCA en el YAML, NUNCA en un `.env` que el compose lea solo (riesgo de commit, reutilización accidental, fuga en logs de CI). Documenta en el runbook qué vars se necesitan y de dónde salen.

## 4. Defaults seguros en variables de ruta de escritura
Toda var de ruta de escritura (datos, adjuntos, backups) se declara `${VAR:-/ruta/segura/de/prod}`. Si el operador olvida setearla, el sistema actúa seguro por defecto; el entorno de prueba la **sobreescribe** explícitamente con su ruta efímera. Nunca una var de escritura sin default en un artefacto que se usa en dev y prod.

## 5. Smoke test contra BD desechable — con el estado inicial de prod
Antes del proceso real, prueba el mecanismo contra una **BD desechable** y **recursos efímeros** (ej. `ADJUNTOS_DIR=/tmp/...`, no el volumen de prod). Regla clave: *la BD desechable debe tener el mismo **estado inicial relevante** que prod, no el mismo dataset* — hay que **sembrar las filas de setup** que prod ya tiene implícitas (registros padre de FKs, config inicial) o el test falla por setup, no por bug. Al final, **verifica que los recursos de prod quedaron intactos**.

Relacionado: [[runner-de-migraciones]], [[restore-drill]], [[revision-de-seguridad]], [[smoke-test-de-navegador]].
