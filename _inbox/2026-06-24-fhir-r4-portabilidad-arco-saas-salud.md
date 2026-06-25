---
tipo: patron
titulo: FHIR R4 Bundle como mecanismo de portabilidad ARCO en SaaS de salud
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: Adaptadores/saas-salud
---

**Qué pasó / contexto:** En Denti (CRM dental SaaS en México), el derecho de acceso y portabilidad ARCO bajo LFPDPPP Art. 22 requería entregar el expediente completo del paciente en un formato estándar, interoperable y no propietario. Se implementó un exportador que genera un Bundle FHIR R4 (type="collection") con recursos Organization, Patient, Condition (diagnósticos CIE-10), Observation (signos vitales).

**Causa raíz / por qué importa:** Sin un estándar de portabilidad, la clínica queda "atrapada" con el proveedor SaaS — el paciente no puede llevar su expediente a otro sistema. En México, la NOM-024 de SIRES y la LFPDPPP exigen que el titular pueda exportar sus datos. FHIR R4 es el estándar internacional de interoperabilidad en salud (HL7), adoptado por IMSS, ISSSTE y proyectos de salud digital en Latinoamérica. Al adoptar FHIR como formato de portabilidad desde el inicio, el producto gana: (a) cumplimiento legal inmediato, (b) posibilidad real de intercambio con otros sistemas, (c) argumento comercial diferenciador.

**Cómo aplicarlo / evitarlo:**
- Definir un puerto `FhirExporter { exportarPaciente(tenantId, entidadId): Promise<FhirBundle> }` desde el inicio. El Bundle es de tipo `collection` (no `transaction`) — no impone orden de procesamiento.
- Recursos mínimos para expediente dental: `Organization` (clínica), `Patient` (datos demográficos), `Condition` (diagnósticos CIE-10), `Observation` (signos vitales), extensión local para odontograma (FHIR no tiene resource dental nativo en R4).
- El route handler de descarga DEBE tener: autenticación, RLS de tenant, `Content-Disposition: attachment`, `Cache-Control: no-store`, `X-Content-Type-Options: nosniff`. Registrar en bitácora de auditoría.
- Usar `application/fhir+json` como Content-Type (MIME oficial de FHIR).
- Fixtures de test SIEMPRE con identificadores ficticios: CURP `XEXX010101HXXXXX00` (RFC extranjero genérico de SAT/RENAPO), nombres `Ficticio/Prueba/Test`.

**¿Específico de un stack?** No en cuanto al patrón; sí en implementación: Node.js / postgres.js para la query, Next.js route handler para la descarga.
