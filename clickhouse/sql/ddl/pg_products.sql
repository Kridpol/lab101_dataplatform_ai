-- Latest row per product_id wins (ReplacingMergeTree); read with FINAL. Safe to re-run.
CREATE TABLE IF NOT EXISTS raw.pg_products
(
    product_id            Int64,
    name                  String,
    category              LowCardinality(String),
    price                 Decimal(10, 2),
    created_at            DateTime64(6, 'UTC'),
    updated_at            DateTime64(6, 'UTC'),
    _airbyte_extracted_at DateTime64(3, 'UTC'),
    _source_file          String
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY product_id;
