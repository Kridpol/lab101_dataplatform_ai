-- Load new products files from SeaweedFS, then record them. Safe to re-run.
-- Money: Airbyte writes NUMERIC as Float64 and a float->Decimal cast truncates (135.7 -> 135.69),
-- so go through the shortest string form, which is exact for two decimals.
INSERT INTO raw.pg_products
    (product_id, name, category, price, created_at, updated_at, _airbyte_extracted_at, _source_file)
SELECT
    CAST(product_id AS Int64), CAST(name AS String), CAST(category AS String),
    CAST(toDecimal64(toString(round(price, 2)), 2) AS Decimal(10, 2)),
    CAST(created_at AS DateTime64(6, 'UTC')), CAST(updated_at AS DateTime64(6, 'UTC')),
    CAST(_airbyte_extracted_at AS DateTime64(3, 'UTC')), _path
FROM s3(seaweedfs_landing, filename = 'raw/pg_products/*.parquet', format = 'Parquet')
WHERE _path NOT IN (SELECT source_file FROM raw._load_log)
SETTINGS s3_throw_on_zero_files_match = 0;

INSERT INTO raw._load_log (source_file, row_count)
SELECT _source_file, count()
FROM raw.pg_products
WHERE _source_file NOT IN (SELECT source_file FROM raw._load_log)
GROUP BY _source_file;
