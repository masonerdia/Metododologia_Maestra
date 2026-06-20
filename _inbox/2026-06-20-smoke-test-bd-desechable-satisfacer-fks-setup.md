---
tipo: bug
titulo: Un smoke test contra BD desechable aún debe satisfacer las FKs de setup que prod ya tiene
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 04-Auditorias
---

**Qué pasó / contexto:** El smoke test del ETL de cutover creaba una BD efímera limpia y corría el script de migración. La BD de prod ya tenía una fila en `clinicas` (FK padre de casi todas las tablas) porque la app lleva meses funcionando. La BD desechable no tenía esa fila, por lo que el INSERT del ETL fallaba por violación de FK — no por un bug del ETL, sino por una precondición de setup que en prod ya estaba satisfecha implícitamente.

**Causa raíz / por qué importa:** Un smoke test bien aislado elimina datos preexistentes para evitar contaminación, pero esa limpieza también elimina las precondiciones que el sistema real da por sentadas. El error no aparece en prod, solo en el test, lo que puede llevar a descartar el smoke test como "falso positivo" o, peor, a no correrlo. La causa raíz es confundir "BD limpia" con "BD en estado equivalente al inicial de prod".

**Cómo aplicarlo / evitarlo:** Al diseñar un smoke test contra una BD desechable: (1) identificar todas las filas de setup que prod tiene y el script asume como precondición (registros padre en tablas maestras, configuración inicial, etc.); (2) insertar esas filas al inicio del smoke test, antes de correr el script bajo prueba; (3) verificar al final que los recursos de prod (volúmenes, tablas reales) no fueron tocados. Regla mnemotécnica: "La BD desechable debe tener el mismo *estado inicial relevante* que prod, no el mismo *conjunto de datos*."

**¿Específico de un stack?** No — aplica a cualquier smoke test de migración/ETL/cutover con una BD aislada.
