-- Files already loaded from SeaweedFS. Safe to re-run.
CREATE TABLE IF NOT EXISTS raw._load_log
(
    source_file String,
    loaded_at   DateTime DEFAULT now(),
    row_count   UInt64
)
ENGINE = MergeTree
ORDER BY source_file;
