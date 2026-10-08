#!/bin/bash
# Idempotent: runs at first start and can be re-run by hand to rotate the S3 key.
# loader may read raw and the S3 collection, and write only raw.
set -euo pipefail

clickhouse client --user default --password "${CLICKHOUSE_PASSWORD}" --multiquery <<SQL
CREATE DATABASE IF NOT EXISTS raw;

DROP NAMED COLLECTION IF EXISTS seaweedfs_landing;
CREATE NAMED COLLECTION seaweedfs_landing AS
    url = 'http://seaweedfs:8333/${SEAWEEDFS_BUCKET}/',
    access_key_id = '${SEAWEEDFS_CLICKHOUSE_ACCESS_KEY}',
    secret_access_key = '${SEAWEEDFS_CLICKHOUSE_SECRET_KEY}';

CREATE USER IF NOT EXISTS ${CLICKHOUSE_LOADER_USER}
    IDENTIFIED WITH sha256_password BY '${CLICKHOUSE_LOADER_PASSWORD}';

GRANT SELECT, INSERT, CREATE TABLE ON raw.* TO ${CLICKHOUSE_LOADER_USER};
GRANT READ ON S3 TO ${CLICKHOUSE_LOADER_USER};
GRANT NAMED COLLECTION ON seaweedfs_landing TO ${CLICKHOUSE_LOADER_USER};
SQL
