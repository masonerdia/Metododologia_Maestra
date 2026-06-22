---
tipo: decision
titulo: Cuándo abandonar una API del browser y moverse a STT server-side
proyecto_origen: Denti
fecha: 2026-06-22
destino_sugerido: 00-Principios
---

**Qué pasó / contexto:** El asistente de voz usaba Web Speech API (`SpeechRecognition`, `continuous=true`). Después de dos hotfixes (cleanup de useEffect, processedUpToRef, rebuild+coalescer), el dictado seguía duplicando en Chrome para Android de la doctora. El bug era específico del dispositivo real y no reproducible en desarrollo. Se tomó la decisión de abandonar Web Speech API y migrar a MediaRecorder + Whisper server-side.

**Causa raíz / por qué importa:** Web Speech API tiene implementaciones notablemente inconsistentes entre Chrome desktop, Chrome Android, y Safari iOS:
- Chrome desktop: `resultIndex` señala correctamente el resultado nuevo.
- Chrome Android con `continuous=true`: finaliza la misma frase como superset creciente en índices nuevos; los workarounds a nivel de cliente (processedUpToRef, rebuild, coalescer) no son suficientemente robustos.
- Safari iOS: no soporta `continuous=true`.

El patrón general: **las APIs del browser que dependen de servicios nativos del SO (reconocimiento de voz, acceso a sensores, cámara) tienen comportamientos divergentes que NO se manifiestan en el emulador o redimensionando el navegador desktop**. Los fixes de cliente pueden funcionar en 9 de 10 dispositivos pero fallar en el exacto dispositivo de producción.

**Cómo aplicarlo / evitarlo:**

**Regla para decidir cuándo migrar a server-side:**

| Señal | Recomendación |
|-------|--------------|
| Bug reproducible SOLO en el dispositivo real | Investigar server-side antes de más workarounds |
| Segundo hotfix sobre el mismo componente sin fix definitivo | Evaluar si la API del browser es adecuada para el caso de uso |
| API con implementaciones divergentes documentadas entre plataformas | Diseñar con server-side desde el inicio |
| Feature crítica para la operación del negocio | Preferir la ruta con menor varianza, aunque sea más lenta |

**Patrón MediaRecorder + Whisper:**
```typescript
// Cliente: grabar con MediaRecorder, enviar blob al detener
const mr = new MediaRecorder(stream, { mimeType: 'audio/webm;codecs=opus' });
mr.ondataavailable = (e) => chunks.push(e.data);
mr.onstop = async () => {
  const blob = new Blob(chunks, { type: mimeType });
  const fd = new FormData();
  fd.append('audio', blob, 'audio.webm');
  const { texto } = await fetch('/api/transcribir', { method: 'POST', body: fd }).then(r => r.json());
  useText(texto);
};
mr.start(250); // chunks frecuentes libera memoria

// Servidor (Node.js route handler): Whisper
const resp = await fetch('https://api.openai.com/v1/audio/transcriptions', {
  method: 'POST',
  headers: { Authorization: `Bearer ${OPENAI_API_KEY}` },
  body: formData, // file + model=whisper-1 + language=es
});
const { text } = await resp.json();
```

**Trade-offs aceptados:**
- Sin transcripción en tiempo real (el texto aparece al soltar el micrófono).
- Latencia de red (el blob viaja al servidor).
- Costo de API (Whisper cobra por minuto).
- **Privacidad**: el audio sale del servidor hacia un tercero — debe documentarse en el aviso de privacidad de la app.

**Patrón de privacidad obligatorio en el route handler:**
- No loguear el audio ni la transcripción (pueden contener PII: nombres de pacientes).
- No propagar mensajes de error de OpenAI al cliente (pueden filtrar detalles internos).
- Verificar autenticación antes de aceptar el audio.
- Documentar el flujo de datos en el aviso de privacidad del producto.

**¿Específico de un stack?** El patrón MediaRecorder + STT cloud es agnóstico de framework. Lo aplica cualquier app web con dictado continuo en producción mobile. El `route.ts` es Next.js App Router, pero el patrón fetch → Whisper aplica a cualquier backend.
