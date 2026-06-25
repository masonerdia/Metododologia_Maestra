---
tipo: patron
titulo: Headers obligatorios en endpoint de descarga de datos de salud — Content-Disposition + no-store + audit log
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Al implementar el endpoint de descarga del expediente FHIR en Denti, se definió el conjunto mínimo de headers de seguridad y el registro obligatorio en bitácora para cualquier endpoint que sirva datos sensibles de salud como descarga.

**Causa raíz / por qué importa:** Un endpoint de descarga sin los headers correctos puede: (a) quedar en caché del navegador o CDN (exposición posterior), (b) ser ejecutado como script si el Content-Type es ambiguo, (c) pasar desapercibido en auditorías de acceso (sin registro = sin trazabilidad legal). En SaaS de salud, la falta de trazabilidad en exportaciones es un incumplimiento de normativas como LFPDPPP, HIPAA o GDPR.

**Cómo aplicarlo / evitarlo:** Para cualquier endpoint que entregue datos de salud como descarga:
```
Content-Disposition: attachment; filename=expediente-<id>.fhir.json
Content-Type: application/fhir+json   (o el MIME del formato)
Cache-Control: no-store
X-Content-Type-Options: nosniff
```
- `no-store`: prohíbe cualquier caché (navegador, proxy, CDN). No usar `no-cache` — permite revalidación, que puede exponer datos.
- `attachment`: fuerza descarga, no apertura inline. Previene que el navegador ejecute el contenido.
- `nosniff`: el navegador no intenta inferir el tipo. Previene XSS via MIME sniffing.
- Registrar en bitácora de auditoría: entidad descargada, usuario, timestamp, IP (sin PII en los logs, solo la entidad_id). El registro debe ser append-only e inalienable.
- El endpoint debe requerir autenticación + autorización de tenant (RLS). Un 404 para accesos de otra clínica es preferible a un 403 (no revela existencia del registro).

**¿Específico de un stack?** No — aplica a cualquier lenguaje/framework. En Next.js: `runtime='nodejs'` (no Edge) para acceder a DB y fs cifrado.
