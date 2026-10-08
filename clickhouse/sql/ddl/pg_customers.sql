-- Latest row per customer_id wins (ReplacingMergeTree); read with FINAL. Safe to re-run.
CREATE TABLE IF NOT EXISTS raw.pg_customers
(
    customer_id           Int64,
    name                  String,
    email                 String,
    country               LowCardinality(String),
    created_at            DateTime64(6, 'UTC'),
    updated_at            DateTime64(6, 'UTC'),
    _airbyte_extracted_at DateTime64(3, 'UTC'),
    _source_file          String
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY customer_id;
