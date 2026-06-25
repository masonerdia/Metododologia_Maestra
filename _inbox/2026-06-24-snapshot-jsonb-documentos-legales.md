---
tipo: patron
titulo: snapshot_json JSONB NOT NULL en tablas append-only para documentos legales
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Al diseñar `consentimiento_firmado` (DENTI-0062), el texto del consentimiento vive en un catálogo editable (`consentimiento_plantilla`). El consentimiento firmado debe ser inmutable aunque la plantilla cambie después. Necesitábamos un mecanismo que congele el contenido en el momento del INSERT.

**Causa raíz / por qué importa:** Si el consentimiento firmado solo guarda `plantilla_id`, un cambio posterior al texto de la plantilla reescribiría retroactivamente el documento que el paciente firmó — invalidando su valor legal y de auditoría. Es el mismo riesgo que existe con precios de tratamiento en presupuestos históricos.

**Cómo aplicarlo / evitarlo:** En toda tabla append-only que representa un documento legal o histórico cuyo contenido puede evolucionar en su catálogo de origen:

1. Añadir `snapshot_json JSONB NOT NULL` con una copia del contenido relevante en el momento del INSERT.
2. Mantener la FK al catálogo (`plantilla_id NULL REFERENCES ... ON DELETE SET NULL`) como trazabilidad de origen, no como fuente de verdad del contenido.
3. Combinar con `REVOKE UPDATE, DELETE` y hash de integridad para inalterabilidad completa.

El campo `nombre TEXT NOT NULL` en la tabla instancia (no solo en la FK) sigue el mismo patrón para el nombre del documento.

**¿Específico de un stack?** No. Aplica a cualquier BD relacional con documentos legales. El JSONB es PostgreSQL-específico; en otros motores usar TEXT/CLOB con JSON serializado.
