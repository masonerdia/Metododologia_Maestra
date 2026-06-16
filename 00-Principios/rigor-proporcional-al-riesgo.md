# Principio · Rigor proporcional al riesgo (tiering)

**Regla:** no todo proyecto merece el rigor completo. Define el **nivel de riesgo** (dinero, datos sensibles, clientes externos, vidas) y aplica los gates en proporción. Un núcleo mínimo para todo; los gates pesados (staging idéntico, restore drills, threat model) solo donde el riesgo lo justifica.

**Por qué:** forzar 11 agentes y 8 checkpoints en un sitio informativo añade fricción sin beneficio y hace que la gente **evada** el proceso. El rigor se respeta cuando es proporcional.

**Núcleo mínimo (todo proyecto):** preview antes de construir, mobile+desktop, build de producción verde, no datos reales, documentar lecciones.
**Rigor alto (dinero/datos sensibles/externos):** + staging idéntico, smoke tests, restore drills, revisión de seguridad, pipeline completo de roles.

Relacionado: [[adopcion-greenfield]], [[adopcion-brownfield]].
