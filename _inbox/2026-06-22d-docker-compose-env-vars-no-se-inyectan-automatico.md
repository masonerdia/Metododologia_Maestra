---
tipo: bug
titulo: Docker Compose no inyecta env vars al contenedor a menos que se declaren explícitamente en environment:
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Se agregó `OPENAI_API_KEY` al `.env` del servidor de producción para habilitar el STT vía Whisper. El endpoint `/api/transcribir` seguía respondiendo 503 "STT no configurado" aunque la clave existiera en el archivo. El servicio `denti-app` en `docker-compose.yml` declaraba otras claves de API (`ANTHROPIC_API_KEY`) pero no la nueva.

**Causa raíz / por qué importa:** Docker Compose no expone automáticamente todas las variables del archivo `.env` al interior del contenedor. Las vars en `.env` sirven como **sustitución en el compose file** (`${VAR}` en el YAML), pero **no se inyectan como variables de entorno del contenedor** a menos que estén listadas en el bloque `environment:` del servicio. Un `.env` completo con 10 vars puede producir un contenedor que "ve" solo 3 si solo 3 están en `environment:`.

Este es un error de categoría silenciosa: el servicio arranca sin error (el compose file no falla), la clave existe en el disco, pero la app ve `undefined` al leer `process.env.OPENAI_API_KEY`.

**Cómo aplicarlo / evitarlo:**

**Regla:** Cada vez que se agrega una nueva variable de entorno al `.env`, verificar que también esté declarada en el bloque `environment:` del servicio que la necesita en `docker-compose.yml`.

**Patrón estándar con valor opcional:**
```yaml
environment:
  NUEVA_API_KEY: ${NUEVA_API_KEY:-}   # vacía si no está en .env, sin romper el compose
```

**Señal de alerta:** Si una feature que depende de `process.env.ALGO` funciona en local (donde Next.js lee `.env.local` directamente) pero falla en producción Docker con "no configurado" o `undefined`, lo primero a revisar es el bloque `environment:` del compose.

**Checklist al integrar un nuevo servicio externo:**
1. Agregar `NUEVA_KEY=` a `.env.example` (documentado).
2. Agregar `NUEVA_KEY:` al bloque `environment:` del servicio en `docker-compose.yml`.
3. Agregar el valor real a `/opt/.env` en producción.
4. Recrear el contenedor (`docker compose up -d <servicio>`, nunca solo `restart`).

**Nota de interacción con Docker:** `docker compose restart` no recarga variables de entorno (nota #12 de CLAUDE.md del proyecto). El único camino es `docker compose up -d <servicio>` que destruye y recrea el contenedor con los nuevos valores.

**¿Específico de un stack?** El comportamiento es de Docker Compose en general, no de Next.js ni de ningún framework específico. Aplica a cualquier servicio dockerizado.
