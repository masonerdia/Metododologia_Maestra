# Adopción · Proyecto ya en producción (brownfield)
El caso difícil. **No empieces cambiando el proceso — empieza por una auditoría de SOLO LECTURA**, que no toca nada y da el diagnóstico.
1. **Auditoría inicial** (read-only): correr `04-Auditorias` (módulo, vista, **flujo**, mobile, seguridad) sobre el proyecto tal como está. Producir un informe priorizado de huecos. Alto valor, cero riesgo.
2. **Instalar gates incrementales:** primero CI con [[ci-build-de-produccion]]; luego [[staging-identico-a-prod]] y [[smoke-test-de-navegador]]; luego [[runner-de-migraciones]] y [[restore-drill]].
3. **Retrofit:** ir cerrando los huecos del informe por prioridad (mobile y seguridad suelen ser los gordos).
4. **Adoptar rituales** ([[abrir-sesion]]/[[cerrar-sesion]], backlog, historial) una vez que los gates dan estabilidad.
No impongas el rigor completo de golpe: genera rechazo. Tiering ([[rigor-proporcional-al-riesgo]]).
