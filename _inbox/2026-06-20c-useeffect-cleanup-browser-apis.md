---
tipo: bug
titulo: useEffect sin cleanup para APIs del browser con estado = instancias zombie
proyecto_origen: Denti
fecha: 2026-06-20
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** El asistente de voz (`AsistenteClient.tsx`) usaba `SpeechRecognition` instanciado dentro de un `useEffect([], [])`. Al navegar fuera y volver a la ruta, React desmontaba y remontaba el componente creando un reconocedor nuevo, pero el viejo seguía vivo porque no había función de cleanup. Ambos reconocedores disparaban `onresult` en paralelo: cada frase llegaba 2-3 veces.

**Causa raíz / por qué importa:** Las APIs del browser con estado propio (SpeechRecognition, AudioContext, WebSocket, MediaRecorder, IntersectionObserver, EventSource) no se destruyen cuando React desmonta el componente. El garbage collector no las puede liberar mientras tengan callbacks activos. En modo dev con StrictMode, React monta-desmonta-monta en el primer render, lo que revela el bug inmediatamente si hay cleanup.

**Cómo aplicarlo / evitarlo:**
- **Regla:** todo `useEffect` que instancie una API del browser con estado DEBE retornar una función de cleanup que la destruya/cierre/detenga.
- Patrón mínimo:
  ```ts
  useEffect(() => {
    const api = new BrowserStatefulAPI();
    // ... configurar ...
    return () => {
      try { api.stop(); } catch {}  // try/catch: puede lanzar si ya está parada
    };
  }, []);
  ```
- Para refs adicionales que los callbacks leen (ej. `escuchandoRef`, `recognizerActiveRef`): resetearlas a `false` en el cleanup antes de llamar `.stop()` para que los `onend`/`onresult` en vuelo no reinicien el ciclo.
- Un guard `recognizerActiveRef` evita el double-start: `if (!recognizerActiveRef.current) { recognizerActiveRef.current = true; api.start(); }`.

**¿Específico de un stack?** No — aplica a cualquier framework con componentes montables/desmontables (React, Vue, Svelte, Angular). El patrón de cleanup es universal.
