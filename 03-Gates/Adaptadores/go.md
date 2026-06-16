# Adaptador — Go [TRANSPORTABLE]

- **Build de producción (gate CI):** `go build ./...` + `go vet ./...` + `go test ./...`. Para binario de release, `CGO_ENABLED=0 go build` reproducible.
- **Smoke test:** arrancar el binario en contenedor; `curl`/Playwright a healthcheck + endpoints clave.
- **Migraciones:** golang-migrate o similar con tabla de control; aplicar solo pendientes.
- **Staging:** misma imagen del binario; mismas variables/headers; datos sanitizados.
- **Gotchas:** errores ignorados (`errcheck`); panics no recuperados en handlers; build tags por entorno.
