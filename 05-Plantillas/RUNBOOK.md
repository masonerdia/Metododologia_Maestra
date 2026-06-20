# RUNBOOK — <operación> (deploy / cutover / restore)   [TRANSPORTABLE]

## Pre-requisitos
<accesos, CI en verde, backup reciente>

## Pasos
```
<comandos exactos, idempotentes, con rutas absolutas>
```

## Verificación
<qué revisar para confirmar éxito (smoke test)>

## Rollback
<cómo revertir; nunca destruir datos; restaurar desde backup>

## Notas
<gotchas, secretos que se respaldan aparte, qué NO tocar>

---

## Convenciones de runbook (aprendidas en operaciones reales)

**Etiqueta el contexto de ejecución de CADA bloque.** Los runbooks de cutover/deploy se ejecutan bajo presión; la ambigüedad "¿dónde corro esto?" causa errores difíciles de revertir (un `scp` en el server en vez de la Mac, un `psql` al host equivocado). Antes de cada bloque pon una etiqueta visible:

```
# === EN EL SERVIDOR (ssh hetzner) ===
...
# === EN TU MAC ===
...
```
Para SSH/SCP, escribe siempre la **forma explícita** además del alias, para que sea ejecutable sin `~/.ssh/config`:
`scp -i ~/.ssh/<clave> -P <puerto> usuario@<ip>:/ruta/origen ~/destino/`

**Separa el código (en git) del runbook narrativo (gitignoreado / wiki privado).** El código que el runbook invoca (scripts, migraciones, compose) va en git, pasa review, es reproducible. El runbook con rutas absolutas, IPs, timing y comandos concretos del entorno itera rápido y puede exponer info de prod → fuera del historial de git. El runbook referencia el código por nombre; el código no conoce al runbook.
