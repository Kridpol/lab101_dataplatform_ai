#!/bin/bash
# dbt reads raw and builds staging and marts. Idempotent: re-run to rotate the password.
set -euo pipefail

CLICKHOUSE_PASSWORD=$(cat /run/secrets/clickhouse_admin_password)
CLICKHOUSE_DBT_PASSWORD=$(cat /run/secrets/clickhouse_dbt_password)

clickhouse client --user default --password "${CLICKHOUSE_PASSWORD}" --multiquery <<SQL
CREATE DATABASE IF NOT EXISTS staging;
CREATE DATABASE IF NOT EXISTS marts;

CREATE USER IF NOT EXISTS ${CLICKHOUSE_DBT_USER} IDENTIFIED WITH sha256_password BY '${CLICKHOUSE_DBT_PASSWORD}';
ALTER USER ${CLICKHOUSE_DBT_USER} IDENTIFIED WITH sha256_password BY '${CLICKHOUSE_DBT_PASSWORD}';

GRANT SELECT ON raw.* TO ${CLICKHOUSE_DBT_USER};
GRANT ALL ON staging.* TO ${CLICKHOUSE_DBT_USER};
GRANT ALL ON marts.* TO ${CLICKHOUSE_DBT_USER};
GRANT CREATE TEMPORARY TABLE ON *.* TO ${CLICKHOUSE_DBT_USER};
SQL
