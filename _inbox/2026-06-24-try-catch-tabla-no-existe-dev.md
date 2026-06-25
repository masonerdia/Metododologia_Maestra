---
tipo: patron
titulo: try/catch silencioso para tablas que pueden no existir en dev (degradación elegante)
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:**
En DENTI-0062 CAPA 3, la página de Historia Clínica consulta `consentimiento_firmado`, `consentimiento_plantilla` y `consentimiento` (tabla legacy). En dev, las migraciones 048/049 pueden no estar aplicadas. El código envuelve cada consulta en `try { ... } catch { /* tabla puede no existir en dev */ }` y usa valores de fallback seguros (false, null, 0).

**Causa raíz / por qué importa:**
Las migraciones no aplicadas en dev provocan crashes en runtime que tsc y next build no detectan (nota #9 del CLAUDE.md: "columnas fantasma"). El try/catch permite que la página funcione parcialmente en dev sin requerir que todas las migraciones estén aplicadas. En producción, donde las migraciones sí están aplicadas, nunca entra al catch.

**Cómo aplicarlo / evitarlo:**
- Cuando un Server Component o server action consulta una tabla nueva (migración reciente), envolver la query en try/catch con valor de fallback seguro.
- Documentar explícitamente el motivo: `/* tabla puede no existir en dev antes de migración NNN */`
- El fallback debe ser el valor más restrictivo/seguro: `false` para booleanos de acceso, `null` para datos opcionales, `0` para conteos.
- NO usar en producción como manejo de errores real — solo como guard de dev environment.
- Asegurarse de que el estado de la página sea coherente con el fallback (por ejemplo, si `tieneConsentimientoGeneral = false`, el semáforo muestra "sin_iniciar" o "por_verificar" — nunca una pantalla rota).

**¿Específico de un stack?** Sí — Next.js App Router Server Components + postgres.js + migraciones manuales. Aplica a cualquier proyecto con migraciones incrementales donde dev y prod pueden tener esquemas distintos temporalmente.
