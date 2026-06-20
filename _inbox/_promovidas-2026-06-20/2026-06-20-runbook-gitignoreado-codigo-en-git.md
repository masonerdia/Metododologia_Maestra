---
tipo: decision
titulo: Separar runbook operacional (gitignoreado) del código ejecutable (en git)
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 01-Gobernanza
---

**Qué pasó / contexto:** Un RUNBOOK de cutover de producción (instrucciones paso a paso para ejecutar la migración, con comandos específicos del entorno, rutas absolutas del servidor y decisiones operacionales) vivía en un directorio gitignoreado del proyecto. El código que ese runbook invoca (scripts ETL, migraciones SQL) estaba en git. Esta separación fue intencional.

**Causa raíz / por qué importa:** Los runbooks de operaciones destructivas (cutover, rollback, disaster recovery) mezclan dos naturalezas distintas:
- **Código ejecutable:** lógica reutilizable, debe pasar por review, estar en git, ser reproducible.
- **Instrucciones operacionales:** específicas del entorno de ejecución (rutas absolutas, IPs, passwords en texto claro en borradores, decisiones de timing), iteran rápido durante la preparación y no deben contaminar el historial de git.

Commitear runbooks operacionales genera ruido en el historial y puede exponer información del entorno de producción.

**Cómo aplicarlo / evitarlo:** Separar explícitamente:

1. **En git:** todo código que el runbook invoca (scripts, migraciones, Dockerfiles, compose files).
2. **Gitignoreado (o en wiki/drive privado):** el runbook narrativo con pasos, comandos concretos del entorno, checklist de verificación, plan de rollback.

El RUNBOOK referencia el código por nombre de archivo/script; el código no conoce al RUNBOOK. Al terminar el cutover, el RUNBOOK puede archivarse o eliminarse sin perder nada reproducible.

**¿Específico de un stack?** No. Patrón de SRE/plataformas aplicable a cualquier operación destructiva en producción.
