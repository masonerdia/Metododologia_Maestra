---
tipo: patron
titulo: ETL dockerizado como runner efímero sobre infraestructura existente del proyecto
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Una migración puntual de datos (legacy Firebird → PostgreSQL) necesitaba acceso simultáneo a la BD de origen y la de destino, con dependencias nativas que no convivían con el entorno de la app. En lugar de instalar dependencias en el host o crear un servicio permanente, se empaquetó el runner ETL como contenedor efímero orquestado por `docker-compose.etl.yml`.

**Causa raíz / por qué importa:** Los procesos de migración son operaciones puntuales, no servicios. Mezclarlos con el compose principal crea residuos (contenedores que quedan corriendo, configuraciones innecesarias en producción) y acopla el ciclo de vida de la migración al de la aplicación.

**Cómo aplicarlo / evitarlo:** Crear un `docker-compose.etl.yml` (o equivalente) separado del compose principal que:

1. Define el runner ETL como servicio con `restart: "no"`.
2. Usa `depends_on: <servicio-origen>: condition: service_healthy` para asegurar que el origen está listo antes de arrancar.
3. Se ejecuta con `docker compose -f docker-compose.etl.yml run --rm etl-runner` — el flag `--rm` elimina el contenedor al terminar.
4. Comparte la red Docker existente del proyecto (`external: true`) para alcanzar la BD de destino sin exponer puertos extra.

El compose de producción permanece limpio; el ETL no deja rastro tras ejecutarse.

**¿Específico de un stack?** No. Aplica a cualquier proceso de migración o tarea batch puntual que necesite deps o configuración distinta a la aplicación principal.
