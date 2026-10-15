-- FINAL keeps the latest version per customer_id (ReplacingMergeTree).
select
    customer_id,
    name           as customer_name,
    lower(email)   as email,
    country,
    created_at,
    updated_at
from {{ source('raw', 'pg_customers') }} final
