---
tipo: patron
titulo: Verificar RLS abriendo conexión sin SET LOCAL app.tenant_id
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 03-Gates
---

**Qué pasó / contexto:**

En DENTI-0059 (Simulacro DGIS) se necesitaba demostrar que el aislamiento multi-tenant con Row-Level Security de PostgreSQL funciona correctamente. El check S12 abre una segunda conexión con las mismas credenciales de la aplicación (`denti_app`) pero SIN ejecutar `SET LOCAL app.clinica_id`, y ejecuta un SELECT en una tabla con RLS activo.

**Causa raíz / por qué importa:**

El patrón estándar de testing de RLS suele fallar porque los tests usan la misma sesión ya autenticada (con `app.clinica_id` seteado). Para probar que el RLS *bloquea* correctamente, hay que probar exactamente el escenario que queremos prevenir: una conexión sin contexto de tenant. Si esa query devuelve filas, el RLS está roto — es una fuga multi-tenant de severidad BLOQUEANTE.

Un error común: usar la conexión de administrador/superusuario para este check — el admin tiene BYPASS RLS y siempre devuelve filas, dando una falsa sensación de seguridad.

La política usa `NULLIF(current_setting('app.clinica_id', true), '')::uuid`. Sin `SET LOCAL`, `current_setting` devuelve `''`, `NULLIF` lo convierte en NULL → la política retorna false → 0 filas (fail-safe).

**Cómo aplicarlo / evitarlo:**

Para cualquier sistema multi-tenant con PostgreSQL RLS:

1. Abrir una segunda conexión con las credenciales de aplicación (no admin):
   ```ts
   const testConn = postgres(DATABASE_URL, { max: 1 });
   ```
2. Ejecutar SELECT en una tabla protegida SIN `SET LOCAL app.tenant_id`:
   ```ts
   const rows = await testConn`SELECT id FROM tabla_con_rls LIMIT 1`;
   ```
3. Afirmar `rows.length === 0` o que lanza `permission denied`.
4. Si devuelve filas → **BLOQUEANTE**: el aislamiento está roto.
5. Cerrar siempre en `finally`: `await testConn.end()`.

Incluir este check en el smoke test de cualquier feature nueva que agregue tablas con RLS. El simulacro DGIS de Denti lo ejecuta de forma automática y periódica (opción: gate en CI).

**¿Específico de un stack?**

Sí, específico de PostgreSQL con Row-Level Security + postgres.js (Node.js). El concepto es trasladable a cualquier ORM que permita abrir una segunda conexión y controlar el contexto de sesión manualmente. No aplica a sistemas que implementan el aislamiento a nivel de aplicación (WHERE clinica_id = $1) sin RLS nativo.
