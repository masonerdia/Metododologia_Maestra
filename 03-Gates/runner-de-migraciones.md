# Gate · Runner de migraciones con ledger

**Qué:** un mecanismo que aplica **solo las migraciones pendientes**, de forma idempotente, y **registra** cuáles se aplicaron (tabla de control / ledger). No aplicar a mano una por una.

**Por qué:** aplicar migraciones manualmente y a pedazos genera confusión ("¿qué está aplicado en prod?"), errores de "ya existe", y código que asume columnas/tablas que no se crearon. Clase entera de bugs evitable.

**Cómo (principio):** una tabla `schema_migrations` (o la del ORM) + un runner que lee pendientes y las corre; numeración sin colisiones; verificación de estado por entorno.

Relacionado: [[integridad-de-dinero-y-datos]].
