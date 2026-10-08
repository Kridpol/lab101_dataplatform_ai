-- Latest row per order_id wins (ReplacingMergeTree); read with FINAL. Safe to re-run.
CREATE TABLE IF NOT EXISTS raw.pg_orders
(
    order_id              Int64,
    customer_id           Int64,
    product_id            Int64,
    quantity              Int32,
    amount                Decimal(10, 2),
    status                LowCardinality(String),
    created_at            DateTime64(6, 'UTC'),
    updated_at            DateTime64(6, 'UTC'),
    _airbyte_extracted_at DateTime64(3, 'UTC'),
    _source_file          String
)
ENGINE = ReplacingMergeTree(updated_at)
ORDER BY order_id;
