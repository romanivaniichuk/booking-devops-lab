#!/usr/bin/env bash

set -euo pipefail

NAMESPACE="${NAMESPACE:-booking}"
BACKUP_DIR="${BACKUP_DIR:-backups}"

mkdir -p "$BACKUP_DIR"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_FILE="${BACKUP_DIR}/booking-${TIMESTAMP}.sql"

kubectl -n "$NAMESPACE" exec deploy/booking-postgres -- \
  sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" pg_dump --clean --if-exists -U "$POSTGRES_USER" -d "$POSTGRES_DB"' \
  > "$BACKUP_FILE"

echo "Backup created: $BACKUP_FILE"
