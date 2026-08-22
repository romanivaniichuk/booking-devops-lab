#!/usr/bin/env bash

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 backups/booking-YYYYMMDD-HHMMSS.sql"
  exit 1
fi

NAMESPACE="${NAMESPACE:-booking}"
BACKUP_FILE="$1"

kubectl -n "$NAMESPACE" exec -i deploy/booking-postgres -- \
  sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" psql -U "$POSTGRES_USER" -d "$POSTGRES_DB"' \
  < "$BACKUP_FILE"

echo "Restore completed: $BACKUP_FILE"
