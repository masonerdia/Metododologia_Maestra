#!/usr/bin/env bash
# sync.sh — versiona y sube la Metodología Maestra a GitHub con un solo comando.
# Uso:
#   ./sync.sh                 -> commit con mensaje automático (fecha) + push
#   ./sync.sh "mi mensaje"    -> commit con tu mensaje + push

set -uo pipefail

REPO_URL="https://github.com/masonerdia/Metododologia_Maestra.git"
BRANCH="main"

# Ir a la carpeta del script (funciona desde cualquier lugar)
cd "$(dirname "$0")" || { echo "❌ no pude entrar a la carpeta"; exit 1; }

echo "📂 $(pwd)"

# 1. Repo git
if [ ! -d .git ]; then
  echo "🔧 git init"
  git init -q
fi

# 2. Rama main
git branch -M "$BRANCH" 2>/dev/null || true

# 3. Remoto origin (agrega si falta, corrige la URL si ya existe)
if git remote get-url origin >/dev/null 2>&1; then
  git remote set-url origin "$REPO_URL"
else
  echo "🔗 remoto origin -> $REPO_URL"
  git remote add origin "$REPO_URL"
fi

# 4. Stage + commit (solo si hay algo que commitear)
git add -A
if git diff --cached --quiet; then
  echo "ℹ️  Sin cambios que commitear."
else
  MSG="${1:-Metodologia Maestra: sync $(date '+%Y-%m-%d %H:%M')}"
  git commit -q -m "$MSG"
  echo "✅ commit: $MSG"
fi

# 5. Push; si lo rechaza (remoto con README/otras historias), sincroniza y reintenta
echo "⬆️  push..."
if ! git push -u origin "$BRANCH" 2>/dev/null; then
  echo "↩️  push rechazado; sincronizando con el remoto..."
  git pull --rebase origin "$BRANCH" 2>/dev/null \
    || git pull --rebase --allow-unrelated-histories origin "$BRANCH"
  git push -u origin "$BRANCH"
fi

echo "🎉 Listo — bóveda sincronizada en GitHub."
