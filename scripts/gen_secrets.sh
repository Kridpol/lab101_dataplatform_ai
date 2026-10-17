#!/bin/bash
# Create any missing secret file in ./secrets with a random value. Existing files are kept.
# Usage: bash scripts/gen_secrets.sh
set -euo pipefail

cd "$(dirname "$0")/.."
mkdir -p secrets
# The directory is owner-only; files stay world-readable so container users can read the mounts.
chmod 700 secrets

names="
pg_admin_password airbyte_pg_password dagster_pg_password
clickhouse_admin_password clickhouse_airbyte_password clickhouse_loader_password clickhouse_dbt_password
seaweedfs_ui_password
seaweedfs_admin_access_key seaweedfs_admin_secret_key
seaweedfs_airbyte_access_key seaweedfs_airbyte_secret_key
seaweedfs_clickhouse_access_key seaweedfs_clickhouse_secret_key
"

for n in $names; do
  f="secrets/$n"
  if [ -s "$f" ]; then
    echo "keep    $n"
  else
    # hex only: safe inside SQL strings and JSON; no trailing newline
    printf '%s' "$(openssl rand -hex 24)" > "$f"
    chmod 644 "$f"
    echo "created $n"
  fi
done
