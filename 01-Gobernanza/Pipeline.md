# Gobernanza · Pipeline

Todo cambio (feature o hotfix, sin excepción por "es chico") recorre:

**[[LEADER]] → [[IMPLEMENTER]] → [[AUDITORES]] → [[GUARDIAN-UX]] (si toca UI) → [[REVIEWER]]**

Y cada sesión cierra con **[[CUSTODIO]] + [[AUDITOR-CIERRE]]** ([[cerrar-sesion]]).

Reglas del pipeline:
- El LEADER **no** codifica; el REVIEWER **no** modifica. Separación de poderes.
- Máximo **1 trabajo in_progress** ([[backlog-max-1-in-progress]]).
- El visto bueno de UX es **adicional** al funcional, no lo reemplaza.
- Una instrucción sin entrada en el backlog → se crea un HOTFIX y sigue el pipeline completo.

**Tiering ([[rigor-proporcional-al-riesgo]]):** en proyectos de bajo riesgo el pipeline puede colapsarse (un solo rol que implementa + auto-revisa con checklist). El pipeline completo es para riesgo alto.

Roles: [[LEADER]] · [[IMPLEMENTER]] · [[AUDITORES]] · [[GUARDIAN-UX]] · [[REVIEWER]] · [[CUSTODIO]] · [[AUDITOR-CIERRE]] · [[CURADOR]]. Excepción: [[especialista-invitado]].
