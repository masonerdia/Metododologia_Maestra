---
tipo: patron
titulo: Migraciones de datos con WHERE defensivo — UPDATE seguro sobre valores placeholder
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** La migración 038 actualiza datos del membrete oficial del consultorio (logo, teléfono, dirección, cédula del médico). Estos datos se configuran en producción vía UI (MembreteEditor), pero en dev/staging vienen de un seed con valores ficticios. Necesitábamos aplicar los valores reales sin pisar datos ya configurados en producción.

**Causa raíz / por qué importa:** Un `UPDATE ... SET x=real` sin WHERE condicional sobreescribe datos ya correctos en producción si el deploy aplica la migración automáticamente. Esto rompe entornos multi-stage (dev/staging/prod con datos distintos) y deshace configuración manual del cliente.

**Cómo aplicarlo / evitarlo:** 
En migraciones que actualizan DATOS (no esquema), usar WHERE que apunte solo a los valores placeholder del seed:
```sql
UPDATE clinicas
SET logo_path = '/brand/oficial.png', telefono = '1234-5678'
WHERE logo_path = '/brand/demo.png'   -- solo el placeholder del seed
  OR telefono  = '5512345678';         -- el teléfono ficticio de demo

UPDATE usuarios
SET cedula_profesional = '3432023', titulo = 'Dra.'
WHERE cedula_profesional = 'Cedula';   -- valor claramente placeholder
```
Si en producción los datos ya están configurados correctamente, el WHERE no matchea y el UPDATE afecta 0 filas (idempotente y no destructivo). En dev/demo afecta solo las filas con datos ficticios.

**¿Específico de un stack?** No. Aplica a cualquier proyecto con migraciones SQL automáticas en pipeline multi-stage.
