# Gate · Staging idéntico a producción

**Qué:** un entorno de pruebas que corre **la misma imagen/artefacto de producción**, con datos sanitizados, los mismos headers de seguridad, el mismo runtime (contenedor, service worker, etc.).

**Por qué:** validar en "dev" no representa prod. Casi todos los incidentes de despliegue se cazan aquí antes de que un usuario los vea. Es la mejora de mayor impacto sobre un proceso que ya tiene tests.

**Cómo (principio):** levantar el build de producción en un entorno aparte; correr ahí el [[smoke-test-de-navegador]] antes de promover a prod.

**Tiering:** indispensable en riesgo alto; opcional en bajo. Ver [[rigor-proporcional-al-riesgo]].
