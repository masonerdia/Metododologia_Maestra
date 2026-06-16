# Principio · Documentar las lecciones (memoria del proyecto)

**Regla:** cada bug resuelto con causa raíz no obvia, cada decisión no trivial y cada gotcha se registra como **nota numerada** en la memoria del proyecto, con su **porqué** y **cómo evitarlo**. Es lo que impide repetir el mismo error.

**Por qué:** el conocimiento que no se escribe se pierde entre sesiones/personas. Los mismos errores reaparecen (ej. exportar no-async en un archivo server, sourcear un `.env` frágil). La nota convierte un dolor en un activo.

**Cómo aplicarlo:** una sección de "notas de arquitectura" + un doc de "errores conocidos"; formato corto: qué pasó, causa raíz, cómo se evita. El agente [[CURADOR]] automatiza la cosecha hacia `_inbox/`.

Relacionado: [[CURADOR]], [[ficha-de-leccion]], [[CHANGELOG]].
