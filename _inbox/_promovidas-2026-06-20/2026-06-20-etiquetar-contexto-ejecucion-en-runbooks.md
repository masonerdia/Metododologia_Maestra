---
tipo: metodo
titulo: Etiquetar explícitamente el contexto de ejecución en cada bloque de un runbook mixto
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 02-Rituales
---

**Qué pasó / contexto:** Un runbook de cutover ETL mezclaba comandos que se ejecutan en el servidor remoto con comandos que se ejecutan en la Mac local (`scp`, `ssh`, `psql` local vs remoto). Sin etiquetas, el operador tenía que inferir el contexto leyendo el comando, lo que genera errores de "ejecuté esto en el lugar equivocado".

**Causa raíz / por qué importa:** Los runbooks de cutover/deploy suelen ser ejecutados bajo presión, con tiempo limitado y a veces por alguien que no escribió los comandos. La ambigüedad de contexto (¿dónde corro esto?) es una fuente habitual de errores operacionales difíciles de revertir. Un `scp` ejecutado en el servidor remoto en vez de local, o un `psql` apuntando al host equivocado, puede tener consecuencias graves.

**Cómo aplicarlo / evitarlo:** En todo runbook con pasos que corren en contextos distintos (servidor remoto / máquina local / contenedor), poner una etiqueta visible antes de cada bloque de código, por ejemplo `**[EN EL SERVIDOR]**` / `**[EN TU MAC]**` / `**[EN EL CONTENEDOR]**`. Además, para comandos SSH/SCP, escribir siempre la forma explícita (`-i ~/.ssh/clave -P puerto user@host`) además del alias del config, para que sea ejecutable incluso sin el `~/.ssh/config` configurado.

**¿Específico de un stack?** No — aplica a cualquier runbook operacional con múltiples contextos de ejecución.
