---
tipo: bug
titulo: Web Speech API continuous=true — staircase por supersets crecientes en Chrome móvil
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** El dictado por voz en `/asistente` producía efecto escalera: "nueva nueva cita nueva cita para mañana…". El primer fix (HOTFIX-VOZ: `processedUpToRef`) no resolvió el problema porque estaba basado en el comportamiento de Chrome desktop, no en el de Chrome móvil.

**Causa raíz / por qué importa:** Chrome móvil con `continuous=true` finaliza la MISMA frase como **superset creciente en un índice nuevo** en cada evento `onresult`:
- Evento 1: `results[0]="nueva"` (final)
- Evento 2: `results[0]="nueva"` (final), `results[1]="nueva cita"` (final)
- Evento 3: `results[0]="nueva"` (final), `results[1]="nueva cita"` (final), `results[2]="nueva cita para"` (final)

Un loop con `+= transcript` appendea cada nuevo índice que pasa el guard, produciendo staircase. `processedUpToRef` no ayuda porque los nuevos índices genuinamente NO han sido procesados.

Este comportamiento **difiere** del de Chrome desktop, donde `resultIndex` señala correctamente el nuevo resultado y los anteriores no se re-envían como finales. La diferencia entre plataformas hace que el bug sea imposible de detectar sin probar en el dispositivo real.

**Cómo aplicarlo / evitarlo:**

**Patrón correcto para `onresult` con `continuous=true`:**
```typescript
r.onresult = (e) => {
  // Rebuild desde cero en cada evento — NO acumular con +=
  let fin = '', interim = '';
  for (let i = 0; i < e.results.length; i++) {
    const t = e.results[i][0].transcript.trim();
    if (e.results[i].isFinal) {
      // Coalescer de superset: si el nuevo final extiende lo ya construido → reemplaza
      if (fin && t.startsWith(fin)) fin = t;
      // Segmento genuinamente nuevo → concatena
      else fin = fin ? fin + ' ' + t : t;
    } else {
      interim += e.results[i][0].transcript;
    }
  }
  // sessionPrefixRef preserva texto de sesiones anteriores (Android endpointing
  // reinicia la sesión → e.results[] vacío; sin prefix se pierde lo ya dicho)
  const prefix = sessionPrefixRef.current;
  const fullFin = prefix ? (fin ? prefix + ' ' + fin : prefix) : fin;
  finalRef.current = fullFin;
  setTranscript(fullFin);
  setInterim(interim);
};

// En onend con restart (endpointing de Android):
sessionPrefixRef.current = finalRef.current;  // snapshot

// En onend con stop (usuario detuvo) y en cleanup de useEffect:
sessionPrefixRef.current = '';
```

**Regla clave:** No asumir que `e.resultIndex` señala únicamente el fragmento nuevo en todos los navegadores. En Chrome móvil, puede haber resultados finales previos en índices menores al de `resultIndex`. El único comportamiento portable es iterar `e.results[0..length]` completo y coalescer los supersets.

**Regla adicional:** los bugs de Web Speech API **solo se reproducen en el dispositivo real**. Emular en desktop o en un resize del navegador no revela el comportamiento de Chrome en Android. Si una sesión de dictado tiene este tipo de bug, la prueba obligatoria es en el dispositivo de producción.

**¿Específico de un stack?** No para la lógica (aplica a cualquier JS/TS que use Web Speech API). Sí en cuanto al comportamiento: específico de Chrome en Android (no Safari iOS, que no soporta `continuous=true`).
