# Principio · Mobile y desktop, siempre

**Regla:** toda vista se diseña y se audita en **ambos modos**. Si el usuario principal opera desde el celular, **mobile manda** (su auditor tiene veto principal); desktop es secundario pero no se descuida.

**Por qué:** una vista que "se ve bien" en desktop puede ser inusable en móvil (y viceversa). El overlay móvil que tapa la columna de escritorio, los targets táctiles chicos, el viewport — se escapan si no se revisa explícitamente en los dos.

**Cómo aplicarlo:** cada feature pasa por [[auditoria-mobile]] y revisión desktop; touch targets ≥44px; probar en viewport real, no solo redimensionando. Ojo: tener DevTools acoplado reduce el viewport y puede disparar el layout móvil — no confundir con bug.

Relacionado: [[auditar-modulo-vista-flujo]], [[GUARDIAN-UX]].
