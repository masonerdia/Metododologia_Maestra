---
tipo: bug
titulo: Web Speech API Chrome continuous=true — resultIndex=0 en todos los eventos, causan duplicados
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: Adaptadores/web-speech-api
---

**Qué pasó / contexto:** Con `recognition.continuous = true`, Chrome re-envía **todos** los results acumulados en cada evento `onresult`, pero con `resultIndex = 0` en lugar del índice real del resultado nuevo. Un loop canónico `for (let i = e.resultIndex; i < e.results.length; i++)` empezaba siempre desde 0, re-procesando segmentos finales ya acumulados. Resultado: cada frase aparecía 3-4 veces en el texto final.

**Causa raíz / por qué importa:** Es un bug/comportamiento no especificado de la implementación de Chrome (Chromium). La spec W3C dice que `resultIndex` debe apuntar al resultado más reciente que cambió, pero Chrome en modo `continuous` lo reinicia a 0 en muchos casos. Firefox y Safari pueden comportarse diferente. El código que se fía ciegamente de `resultIndex` como punto de partida produce duplicados silenciosamente.

**Cómo aplicarlo / evitarlo:**
- **Patrón `processedUpToRef`:** llevar un ref que registra el índice más alto de `results[]` ya procesado.
  ```ts
  const processedUpToRef = useRef(0);

  recognition.onresult = (e) => {
    for (let i = e.resultIndex; i < e.results.length; i++) {
      if (e.results[i].isFinal && i >= processedUpToRef.current) {
        accumulated += e.results[i][0].transcript + ' ';
        processedUpToRef.current = i + 1;   // marcar como procesado
      }
    }
  };

  // Al iniciar una nueva sesión STT (onend reinicia o toggle):
  processedUpToRef.current = 0;
  ```
- Resetear `processedUpToRef.current = 0` al inicio de **cada** nueva sesión STT — porque el índice es relativo a la sesión, no global.
- Nunca asumir que `e.resultIndex > 0` en Chrome `continuous=true`; tratar siempre `resultIndex` como potencialmente incorrecto.

**¿Específico de un stack?** Sí — Web Speech API. Aplica a React, Vue, Svelte, Vanilla JS. Va al adaptador `Adaptadores/web-speech-api`.
