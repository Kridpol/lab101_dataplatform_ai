#!/bin/sh
# Run SQL files (paths relative to /sql) as the loader user, e.g.: sh /sql/run.sh ddl/pg_orders.sql load/pg_orders.sql
set -eu
CLICKHOUSE_LOADER_PASSWORD=$(cat /run/secrets/clickhouse_loader_password)
for f in "$@"; do
  echo "-> $f"
  clickhouse-client --user "$CLICKHOUSE_LOADER_USER" --password "$CLICKHOUSE_LOADER_PASSWORD" --multiquery < "/sql/$f"
done
