select
    product_id,
    name   as product_name,
    category,
    price,
    created_at,
    updated_at
from {{ source('raw', 'pg_products') }} final
