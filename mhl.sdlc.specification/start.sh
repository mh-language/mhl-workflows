#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

# Load local configuration when available.
if [[ -f "$SCRIPT_DIR/.env" ]]; then
  set -a
  # shellcheck disable=SC1091
  source "$SCRIPT_DIR/.env"
  set +a
fi

POSTGRES_DB="${POSTGRES_DB:-specification}"
POSTGRES_USER="${POSTGRES_USER:-specification}"
POSTGRES_PASSWORD="${POSTGRES_PASSWORD:-specification}"
POSTGRES_PORT="${POSTGRES_PORT:-5432}"
MHL_PORT="${MHL_PORT:-8713}"

export POSTGRES_DB POSTGRES_USER POSTGRES_PASSWORD POSTGRES_PORT
export DATABASE_URL="postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@127.0.0.1:${POSTGRES_PORT}/${POSTGRES_DB}"

echo "Iniciando PostgreSQL..."
docker compose \
  --project-directory "$SCRIPT_DIR" \
  --file "$COMPOSE_FILE" \
  up -d --wait postgres

if ! command -v lsof >/dev/null 2>&1; then
  echo "Erro: lsof é necessário para liberar a porta $MHL_PORT." >&2
  exit 1
fi

MHL_PIDS="$(lsof -tiTCP:"$MHL_PORT" -sTCP:LISTEN 2>/dev/null || true)"
if [[ -n "$MHL_PIDS" ]]; then
  echo "Encerrando processo(s) na porta $MHL_PORT: $MHL_PIDS"
  for pid in $MHL_PIDS; do
    kill "$pid" 2>/dev/null || true
  done
fi

echo "DATABASE_URL configurada para o processo MHL."
exec mhl serve mcp --http --addr "127.0.0.1:$MHL_PORT" --state-dir .
