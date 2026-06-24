---
tipo: bug
titulo: Subconsulta correlacionada vs LEFT JOIN al agregar múltiples tablas por entidad
proyecto_origen: Denti
fecha: 2026-06-23
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** Al calcular el saldo por paciente (aging) en el módulo /finanzas, un `LEFT JOIN cargos ... LEFT JOIN abonos` producía resultados incorrectos: si un paciente tenía 3 cargos y 5 abonos, el JOIN generaba 15 filas (3×5), y el SUM multiplicaba los montos.

**Causa raíz / por qué importa:** `LEFT JOIN` entre dos tablas de muchos (cargos y abonos del mismo paciente) produce un producto cartesiano de las filas coincidentes. El SUM suma cada cargo por cada abono y viceversa — el resultado es mayor al real. El bug es silencioso: la query no falla, devuelve un número plausible pero incorrecto.

**Cómo aplicarlo / evitarlo:** Usar subconsultas correlacionadas independientes en lugar de JOINs cuando necesitas agregar múltiples relaciones 1:N de la misma entidad:

```sql
SELECT
  p.id,
  p.nombre,
  (SELECT COALESCE(SUM(c.monto_centavos - c.descuento_centavos), 0)
     FROM cargos c WHERE c.paciente_id = p.id AND c.deleted_at IS NULL) AS total_cargos,
  (SELECT COALESCE(SUM(a.monto_centavos), 0)
     FROM abonos a WHERE a.paciente_id = p.id AND a.deleted_at IS NULL) AS total_abonos
FROM pacientes p
WHERE p.deleted_at IS NULL
ORDER BY (total_cargos - total_abonos) DESC;
```

Alternativa equivalente con subqueries en FROM: `LEFT JOIN (SELECT paciente_id, SUM(...) FROM cargos GROUP BY paciente_id) g ON ...` — evita el cross-product sin subconsultas correlacionadas, más eficiente con índices.

**Señal de alerta:** Si el SUM de una entidad cambia al agregar otro JOIN, hay un producto cartesiano.

**¿Específico de un stack?** No — es SQL estándar. Aplica a cualquier BD relacional.
