#!/bin/sh
# Usage: entrypoint.sh webserver|daemon. The venv is cached in the dagster-venv volume.
set -e
[ -x /opt/venv/bin/pip ] || python -m venv /opt/venv
/opt/venv/bin/pip install -q --no-cache-dir -r /opt/dagster/requirements.txt
export PATH="/opt/venv/bin:$PATH"   # dagster-dbt looks for `dbt` on PATH

DAGSTER_PG_PASSWORD=$(cat /run/secrets/dagster_pg_password)
AIRBYTE_CLIENT_ID=$(cat /run/secrets/airbyte_client_id)
AIRBYTE_CLIENT_SECRET=$(cat /run/secrets/airbyte_client_secret)
CLICKHOUSE_LOADER_PASSWORD=$(cat /run/secrets/clickhouse_loader_password)
CLICKHOUSE_DBT_PASSWORD=$(cat /run/secrets/clickhouse_dbt_password)
export DAGSTER_PG_PASSWORD AIRBYTE_CLIENT_ID AIRBYTE_CLIENT_SECRET CLICKHOUSE_LOADER_PASSWORD CLICKHOUSE_DBT_PASSWORD

case "$1" in
  webserver) exec /opt/venv/bin/dagster-webserver -h 0.0.0.0 -p 3000 -w /opt/dagster/workspace.yaml ;;
  daemon)    exec /opt/venv/bin/dagster-daemon run -w /opt/dagster/workspace.yaml ;;
  *)         echo "usage: entrypoint.sh webserver|daemon" >&2; exit 1 ;;
esac
