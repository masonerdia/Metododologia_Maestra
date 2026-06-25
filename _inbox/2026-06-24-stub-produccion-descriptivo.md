---
tipo: patron
titulo: Stub de producción descriptivo — lanzar error con instrucciones exactas en lugar de silencio o NO-OP
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: Adaptadores/general
---

**Qué pasó / contexto:**
En Denti (DENTI-0054) el `ProdSigner` es un adaptador que no puede implementarse hasta que el consultorio contrate un PSC acreditado, obtenga e.firma SAT y configure una TSA NOM-151. Mientras tanto, `DOCUMENT_SIGNER=dev` es el default. Si alguien configura `DOCUMENT_SIGNER=prod` sin los recursos necesarios, el sistema debe fallar claro y temprano.

**El anti-patrón:**
```ts
// Malo: falla silenciosa
async firmar(doc: Buffer): Promise<SobreFirmado> {
  return { version: '1', firma: '', ... }; // retorna datos vacíos
}
// Malo: error genérico
throw new Error('Not implemented');
```

**El patrón correcto — error descriptivo con checklist:**
```ts
const INSTRUCCIONES = `
ProdSigner no está configurado. Para firma avanzada en producción se requiere:
  1. PSC acreditado (SAT o equivalente) con certificado X.509 vigente
  2. e.firma (FIEL) vigente del representante legal del consultorio
  3. TSA (Time Stamping Authority) compatible NOM-151-SCFI-2016
  4. Variable de entorno: DOCUMENT_SIGNER=prod
  5. Variables adicionales: SIGNER_CERT_PATH, SIGNER_KEY_PATH, SIGNER_TSA_URL

Mientras tanto, usar DOCUMENT_SIGNER=dev (default) para desarrollo y pruebas.
`.trim();

export class ProdSigner implements DocumentSigner {
  async firmar(_documento: Buffer, _certificado: CertificadoFirma): Promise<SobreFirmado> {
    throw new Error(INSTRUCCIONES);
  }
  async verificar(_sobre: SobreFirmado): Promise<boolean> {
    throw new Error(INSTRUCCIONES);
  }
}
```

**Por qué funciona:**
- El error aparece en los logs con contexto accionable — no hay que buscar en el código qué falta.
- Los tests pueden verificar el mensaje: `expect(...).rejects.toThrow(/PSC acreditado|DOCUMENT_SIGNER=prod/i)`.
- El stub implementa la interfaz completa → TypeScript no se queja, no hay `as any`.
- Cuando el equipo tenga los recursos, sustituye el `throw` por la implementación real — el resto del código no cambia.

**Cuándo usar este patrón:**
- Adaptadores que dependen de recursos externos de producción (PSC, gateways de pago, TSA, APIs de terceros con costo).
- Integraciones que requieren aprobación legal o contractual antes de activarse.
- Cualquier funcionalidad "diferida" que no debe silenciarse en dev ni bloquear el desarrollo.

**¿Específico de un stack?** No — el patrón aplica en cualquier lenguaje con excepciones. El formato del mensaje puede variar.
