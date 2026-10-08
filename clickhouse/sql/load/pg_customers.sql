-- Load new customers files from SeaweedFS, then record them. Safe to re-run:
-- CAST fails loudly on unexpected NULLs; a rerun after a crash only adds identical rows.
INSERT INTO raw.pg_customers
    (customer_id, name, email, country, created_at, updated_at, _airbyte_extracted_at, _source_file)
SELECT
    CAST(customer_id AS Int64), CAST(name AS String), CAST(email AS String), CAST(country AS String),
    CAST(created_at AS DateTime64(6, 'UTC')), CAST(updated_at AS DateTime64(6, 'UTC')),
    CAST(_airbyte_extracted_at AS DateTime64(3, 'UTC')), _path
FROM s3(seaweedfs_landing, filename = 'raw/pg_customers/*.parquet', format = 'Parquet')
WHERE _path NOT IN (SELECT source_file FROM raw._load_log)
SETTINGS s3_throw_on_zero_files_match = 0;

INSERT INTO raw._load_log (source_file, row_count)
SELECT _source_file, count()
FROM raw.pg_customers
WHERE _source_file NOT IN (SELECT source_file FROM raw._load_log)
GROUP BY _source_file;
