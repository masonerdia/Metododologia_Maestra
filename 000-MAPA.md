# 🗺️ 000 · MAPA — Metodología Maestra

> Punto de entrada. Recorre de arriba hacia abajo: el **porqué** (principios), el **cómo se organiza** (gobernanza, rituales), el **cómo se controla** (gates, auditorías), y las **herramientas** (plantillas, adopción). En el **graph view** verás cómo un principio se conecta con el gate que lo hace cumplir y la auditoría que lo verifica.

## 00 · Principios (el porqué)
[[no-datos-reales-de-usuarios]] · [[integridad-de-dinero-y-datos]] · [[mobile-y-desktop-siempre]] · [[done-es-desplegado-y-verificado]] · [[preview-antes-de-construir]] · [[una-sola-fuente-de-verdad]] · [[documentar-las-lecciones]] · [[auditar-modulo-vista-flujo]] · [[rigor-proporcional-al-riesgo]]

## 01 · Gobernanza (quién hace qué)
[[Pipeline]] de roles → [[LEADER]] · [[IMPLEMENTER]] · [[AUDITORES]] · [[GUARDIAN-UX]] · [[REVIEWER]] · [[CUSTODIO]] · [[AUDITOR-CIERRE]]
Agente [[CURADOR]] (cosecha lecciones) · [[especialista-invitado]]

## 02 · Rituales (sesión a sesión)
[[abrir-sesion]] · [[cerrar-sesion]] · [[backlog-max-1-in-progress]] · [[history-append-only]] · [[consolidar-notas]]

## 03 · Gates (frontera con producción)
[[ci-build-de-produccion]] · [[staging-identico-a-prod]] · [[smoke-test-de-navegador]] · [[runner-de-migraciones]] · [[migraciones-y-procesos-destructivos]] · [[restore-drill]] · [[revision-de-seguridad]] · [[observabilidad]]
Implementación por stack → `03-Gates/Adaptadores/`

## 04 · Auditorías (revisar antes de publicar)
[[auditoria-por-modulo]] · [[auditoria-por-vista]] · [[auditoria-por-flujo]] · [[auditoria-mobile]] · [[auditoria-de-seguridad]] · [[auditoria-integral]]

## 05 · Plantillas (TRANSPORTABLES — se copian a proyectos)
`05-Plantillas/`: [[SPEC]] · [[RUNBOOK]] · [[checklist-validacion]] · [[CLAUDE-base]] · [[AGENTS-base]] · [[ficha-de-leccion]]

## 06 · Adopción (cómo migrar la metodología)
[[adopcion-greenfield]] · [[adopcion-brownfield]] · [[rigor-proporcional-al-riesgo]]

## 07 · Proyectos (instancias)
[[Denti]] — referencia "100% aplicado"

---
*La maestra es viva: lecciones nuevas entran por `_inbox/` y se registran en [[CHANGELOG]].*
