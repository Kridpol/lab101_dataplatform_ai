select order_id, quantity, amount
from {{ ref('stg_pg_orders') }}
where quantity <= 0 or amount < 0
