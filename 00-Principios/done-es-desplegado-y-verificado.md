# Principio · "Done" = desplegado y verificado, no mergeado

**Regla:** una feature no está terminada cuando el código pasa tests locales; está terminada cuando está **desplegada y verificada funcionando en el entorno real** (idealmente prod o staging idéntico).

**Por qué:** la mayoría de los incidentes viven en la **frontera con producción** — cosas que pasan `tsc`/unit pero fallan en el build de producción, en el contenedor real, con el service worker, con los headers. "Mergeado" da una falsa sensación de terminado.

**Cómo aplicarlo:** el build de producción es un gate ([[ci-build-de-produccion]]); tras desplegar, un recorrido de verificación ([[smoke-test-de-navegador]]) de los flujos críticos. Ver también [[staging-identico-a-prod]].

Relacionado: [[ci-build-de-produccion]], [[smoke-test-de-navegador]], [[cerrar-sesion]].
