select
    order_id,
    customer_id,
    product_id,
    quantity,
    amount,
    status,
    created_at   as ordered_at,
    updated_at
from {{ source('raw', 'pg_orders') }} final
