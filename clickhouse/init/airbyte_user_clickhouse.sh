set -euo pipefail

CLICKHOUSE_AIRBYTE_PASSWORD=$(cat /run/secrets/clickhouse_airbyte_password)

clickhouse client --user default --password "${CLICKHOUSE_PASSWORD}" --multiquery <<SQL
CREATE DATABASE IF NOT EXISTS raw;

-- async_insert = 0: the Airbyte destination needs synchronous inserts.
CREATE USER IF NOT EXISTS ${CLICKHOUSE_AIRBYTE_USER}
    IDENTIFIED WITH sha256_password BY '${CLICKHOUSE_AIRBYTE_PASSWORD}'
    SETTINGS async_insert = 0;

-- Airbyte may only touch `raw`.
GRANT ALL ON raw.* TO ${CLICKHOUSE_AIRBYTE_USER};
SQL
