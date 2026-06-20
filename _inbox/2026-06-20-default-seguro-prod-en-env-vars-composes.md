---
tipo: patron
titulo: Env vars de rutas de escritura con default seguro de prod (${VAR:-/ruta/prod})
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Un `docker-compose.etl.yml` usaba una variable `ADJUNTOS_DIR` sin default. El smoke test necesitaba escribir en `/tmp/adjuntos-smoke` (efímero), pero el cutover real debía usar el volumen de prod. Solución: declarar la variable con `${ADJUNTOS_DIR:-/var/denti/adjuntos}` en el compose; el smoke test sobreescribe la var en el shell, el cutover real la omite y cae al default seguro.

**Causa raíz / por qué importa:** Una variable sin default hace que el comportamiento en producción dependa de que el operador recuerde setear la variable. Si se olvida, el default implícito es vacío (`""`), lo que puede resultar en escrituras en el directorio de trabajo actual o un error oscuro. Un default que apunte a la ruta de prod invierte el riesgo: si el operador olvida la variable, el sistema actúa de forma segura por defecto.

**Cómo aplicarlo / evitarlo:** En cualquier compose o script que maneje rutas de escritura (datos, adjuntos, backups, logs persistentes): declarar `${NOMBRE_VAR:-/ruta/segura/de/prod}`. El entorno de prueba/smoke sobreescribe con su ruta efímera explícitamente. Nunca dejar una variable de ruta de escritura sin default en artefactos que se usan tanto en smoke/dev como en prod.

**¿Específico de un stack?** No — aplica a cualquier compose, script bash o Dockerfile con vars de rutas de escritura.
