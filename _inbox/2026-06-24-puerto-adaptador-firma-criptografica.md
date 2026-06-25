---
tipo: patron
titulo: Puerto + adaptador para firma criptográfica — DevSigner/ProdSigner sin dependencias de terceros en dev
proyecto_origen: Denti
fecha: 2026-06-24
destino_sugerido: Adaptadores/criptografia
---

**Qué pasó / contexto:**
En Denti (DENTI-0054) se necesitaba firma electrónica avanzada (RSA-SHA256 + CAdES/XAdES + TSA NOM-151) para documentos clínicos. La firma de producción requiere un PSC acreditado (SAT), e.firma vigente del representante legal, y una TSA compatible con NOM-151-SCFI-2016 — recursos que no existen en dev ni en las primeras iteraciones.

**Causa raíz / por qué importa:**
Sin la separación puerto/adaptador, el código del dominio quedaría acoplado al proveedor de producción desde el primer día, o habría condicionales `if (process.env.NODE_ENV === 'development')` mezclados en la lógica del negocio. En producción, el proveedor puede cambiar (PSC A → PSC B) sin tocar el dominio.

**Cómo aplicarlo:**
1. Definir un puerto (interfaz pura) en `lib/ports/`:
```ts
// lib/ports/document-signer.ts
export interface DocumentSigner {
  firmar(documento: Buffer, certificado: CertificadoFirma): Promise<SobreFirmado>;
  verificar(sobre: SobreFirmado): Promise<boolean>;
}
```
2. Implementar `DevSigner` en `lib/adapters/signer/dev-signer.ts` usando SOLO `node:crypto` (RSA-2048 efímero o clave propia, RSA-SHA256). Sin librerías de terceros. Funciona offline, sin variables de entorno.
3. Implementar `ProdSigner` como stub que lanza error descriptivo (ver ficha "stub de producción descriptivo").
4. Exponer factory `getDocumentSigner()` singleton en `lib/signer.ts`. El dominio solo importa la factory, nunca los adaptadores directamente.
5. Controlar con variable de entorno: `DOCUMENT_SIGNER=dev` (default) | `DOCUMENT_SIGNER=prod`.

**Invariante de dominio capturada en el tipo `SobreFirmado`:**
```ts
export interface SobreFirmado {
  version: '1';
  algoritmo: 'RSA-SHA256';
  formato: 'dev-json' | 'cades' | 'xades';
  documento: string;    // base64 del buffer original
  firma: string;        // base64 de la firma
  certificado: string;  // base64 de la clave pública (dev) o X.509 (prod)
  timestamp: string;    // ISO 8601 UTC
  selloTiempo?: string; // RFC 3161 TSA base64 (solo prod)
  hash: string;         // sha256 hex del documento
}
```

El `DevSigner` efímero (sin cert) genera su propio par RSA-2048 en cada `firmar()`. El `DevSigner` con cert usa el par proporcionado. Ambos modos comparten el mismo `verificar()`.

**Tabla persistente append-only:**
Los sobres firmados se guardan en una tabla `sobre_firmado` con REVOKE UPDATE/DELETE (append-only) + RLS tenant. El campo `documento` puede omitirse de la columna `sobre_json` por tamaño; el `hash` sha256 actúa como ancla de integridad.

**¿Específico de un stack?** No — el patrón puerto/adaptador aplica en cualquier lenguaje. La implementación con `node:crypto` es específica de Node.js/TypeScript.
