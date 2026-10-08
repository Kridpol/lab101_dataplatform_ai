-- Load new orders files from SeaweedFS, then record them. Safe to re-run.
-- Money: go through the shortest string form (a float->Decimal cast truncates, 135.7 -> 135.69).
INSERT INTO raw.pg_orders
    (order_id, customer_id, product_id, quantity, amount, status, created_at, updated_at, _airbyte_extracted_at, _source_file)
SELECT
    CAST(order_id AS Int64), CAST(customer_id AS Int64), CAST(product_id AS Int64), CAST(quantity AS Int32),
    CAST(toDecimal64(toString(round(amount, 2)), 2) AS Decimal(10, 2)), CAST(status AS String),
    CAST(created_at AS DateTime64(6, 'UTC')), CAST(updated_at AS DateTime64(6, 'UTC')),
    CAST(_airbyte_extracted_at AS DateTime64(3, 'UTC')), _path
FROM s3(seaweedfs_landing, filename = 'raw/pg_orders/*.parquet', format = 'Parquet')
WHERE _path NOT IN (SELECT source_file FROM raw._load_log)
SETTINGS s3_throw_on_zero_files_match = 0;

INSERT INTO raw._load_log (source_file, row_count)
SELECT _source_file, count()
FROM raw.pg_orders
WHERE _source_file NOT IN (SELECT source_file FROM raw._load_log)
GROUP BY _source_file;
