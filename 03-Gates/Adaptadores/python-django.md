# Adaptador — Python / Django [TRANSPORTABLE]

- **Build/verificación (gate CI):** `python manage.py check --deploy` + `collectstatic --noinput` + `pytest`. El `--deploy` atrapa configuración insegura para prod.
- **Smoke test:** Playwright o `requests` contra el contenedor: login + endpoints clave → 200 + contenido esperado.
- **Migraciones:** `manage.py migrate` (Django ya lleva ledger en `django_migrations`); en CI, `makemigrations --check --dry-run` para detectar migraciones faltantes.
- **Staging:** misma imagen (gunicorn/uvicorn), `DEBUG=False`, mismos headers, datos sanitizados.
- **Gotchas:** `DEBUG=True` accidental en prod; estáticos sin servir; secretos en settings en vez de entorno/gestor.
