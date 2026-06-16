# Gate · Revisión de seguridad / higiene de secretos

**Qué:** una pasada periódica (y como gate antes de exponer a clientes externos): manejo de secretos, headers, políticas de permisos del navegador, aislamiento de tenant, datos sensibles, superficie de ataque.

**Por qué:** lo que es aceptable en validación interna no lo es con clientes externos y datos reales. Los secretos en `.env` planos, una política de permisos mal puesta (que puede romper features además de exponer), o un servidor compartido, son riesgos que crecen con el producto.

**Cómo (principio):** gestor de secretos en vez de `.env` plano cuando escale; threat model ligero; revisar headers/CSP/permissions-policy; confirmar aislamiento multi-tenant con tests.

Relacionado: [[no-datos-reales-de-usuarios]], [[restore-drill]].
