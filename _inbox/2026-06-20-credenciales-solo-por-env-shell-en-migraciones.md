---
tipo: patron
titulo: Credenciales de procesos de migración solo por env del shell, nunca en el compose
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Un `docker-compose.etl.yml` orquesta un proceso de migración con acceso a la BD de producción. Las credenciales (contraseña de BD, password de sistema legacy) se referenciaron como `${VAR}` en el compose, requiriendo que el operador las exporte en el shell antes de ejecutar. No se usó `.env` ni hardcoding en el archivo YAML.

**Causa raíz / por qué importa:** Un proceso ETL/migración tiene acceso privilegiado a datos de producción. Si las credenciales quedan en un `.env` que el compose lee automáticamente, o peor, hardcodeadas en el YAML, existe riesgo de:
- Commit accidental al repositorio.
- Reutilización inadvertida de credenciales al ejecutar `docker compose up` en otro contexto.
- Exposición en logs de CI/CD.

Los procesos con acceso a producción deben requerir acción explícita del operador para recibir credenciales.

**Cómo aplicarlo / evitarlo:** En el compose de migración, referenciar todas las credenciales como variables de entorno sin valor por defecto:

```yaml
environment:
  - DB_PASSWORD=${DB_PROD_PASSWORD}
  - LEGACY_PASSWORD=${LEGACY_SYSDBA_PASSWORD}
```

El operador debe exportar las variables en el shell antes de ejecutar. Si alguna no está definida, Docker Compose advierte (o falla con `--env-file /dev/null`). Documentar en el RUNBOOK qué variables son necesarias y cómo obtenerlas de la bóveda de secretos.

**¿Específico de un stack?** No. Aplica a cualquier proceso batch/migración con acceso a datos sensibles, independientemente de la tecnología de orquestación.
