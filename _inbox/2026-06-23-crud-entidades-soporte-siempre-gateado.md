---
title: Las entidades de soporte/configuración necesitan CRUD propio gateado por rol
date: 2026-06-23
source: Denti HOTFIX-0024
tags: [saas, ux, backend, rbac, onboarding, crud]
---

## Lección

En cualquier SaaS con roles, las entidades de configuración (profesionales, categorías, sucursales, tarifas, etiquetas) suelen sembrarse con datos iniciales pero no reciben pantalla de administración porque "no están en el MVP". Resultado: la entidad queda de facto inmutable desde la UI, y cualquier cambio requiere ir a la BD o al soporte.

La regla: **toda entidad de referencia que el tenant necesite modificar debe tener su CRUD propio, gateado al rol administrador, desde el primer momento en que se usa en producción**.

## Por qué importa

Si el catálogo de referencia no tiene UI de gestión:
- El onboarding queda incompleto (el tenant no puede agregar sus propios datos).
- Las operaciones del día a día (agendar, facturar, asignar) fallan silenciosamente cuando se referencia una entidad que el sistema no tiene.
- Se acumula deuda de soporte: cada alta de un nuevo doctor/categoría/sucursal requiere intervención técnica.
- En flujos de voz/chat, el asistente choca contra entidades inexistentes y no puede recuperarse sin el CRUD de respaldo.

## Cómo aplicar

Al diseñar cualquier feature que referencie una entidad de configuración, agregar al mismo ticket:
- [ ] Pantalla de listado con soft-delete (no hard delete para preservar historia).
- [ ] Formulario de alta/edición inline o en modal.
- [ ] Gate de rol: solo el administrador/dueño puede modificar.
- [ ] Link de acceso desde el módulo principal que usa esa entidad (no enterrado en "Configuración > Avanzado").
- [ ] Seed de datos ficticios para demo/dev.

**Checklist de entidades de soporte habituales en SaaS:**
- Profesionales / usuarios operativos
- Categorías / tipos de producto o servicio
- Sucursales / ubicaciones
- Métodos de pago disponibles
- Plantillas de mensajes
- Tarifas / listas de precio

Si alguna de estas existe en BD pero no tiene CRUD en UI al ir a producción, está incompleta.
