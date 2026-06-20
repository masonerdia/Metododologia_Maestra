---
tipo: patron
titulo: Modo de ejecución de scripts de migración configurable por env var, no por flags CLI ni constantes
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Un script ETL podía correr en modo TEST (genera reporte sin escribir en producción) o modo PROD (escritura real). En lugar de usar flags CLI (`--dry-run`) o constantes hardcodeadas, el comportamiento se controló con `ETL_MODO=TEST|PROD` leída al inicio del script, con `TEST` como valor por defecto seguro.

**Causa raíz / por qué importa:** Los scripts de migración son peligrosos: una ejecución accidental en modo producción puede ser irreversible. Las constantes hardcodeadas requieren modificar el archivo antes de cada ejecución (riesgo de olvidar revertirlo). Los flags CLI dependen de que el operador los recuerde y los escriba correctamente cada vez. Una env var:
- Es explícita y observable (`echo $ETL_MODO` antes de ejecutar).
- Puede forzarse a un valor seguro por defecto en el compose.
- Se puede auditar en logs de shell (`export` muestra las variables activas).
- Facilita el smoke test: `ETL_MODO=TEST docker compose run --rm etl-runner`.

**Cómo aplicarlo / evitarlo:** En el script de migración:

```typescript
const modo = (process.env.ETL_MODO ?? 'TEST') as 'TEST' | 'PROD';
if (modo !== 'TEST' && modo !== 'PROD') {
  throw new Error(`ETL_MODO inválido: "${modo}". Usar TEST o PROD.`);
}
```

En el compose de ETL, dejar el valor vacío (forzará el default seguro) o documentar que el operador debe exportar `ETL_MODO=PROD` explícitamente antes del cutover real. El RUNBOOK incluye el paso de verificación: "confirmar `echo $ETL_MODO` = PROD antes de ejecutar".

**¿Específico de un stack?** No. El patrón aplica a cualquier script de migración/ETL en cualquier lenguaje. La convención `DRY_RUN=true|false` o `MODE=dry|live` es equivalente.
