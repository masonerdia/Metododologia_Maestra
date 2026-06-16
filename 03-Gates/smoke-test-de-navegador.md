# Gate · Smoke test de navegador (post-deploy)

**Qué:** un recorrido mínimo automatizado (o checklist manual) que, tras desplegar, abre la app real y verifica los **flujos críticos**: login, cargar 2-3 pantallas clave, que **hidrata** (los clics responden), sin errores en consola/red.

**Por qué:** un build verde puede desplegar una app que "se ve" pero no responde (hidratación rota, chunks faltantes, service worker viejo). El smoke test lo caza en segundos en vez de que lo reporte el usuario.

**Cómo (principio):** Playwright/equivalente para automatizar; o un checklist de "hard refresh + recorrer flujos + revisar consola" como mínimo. Parte de [[done-es-desplegado-y-verificado]].
