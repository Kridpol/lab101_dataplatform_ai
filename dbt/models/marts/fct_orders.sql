{{ config(order_by='(order_date, order_id)') }}

-- One row per order. Revenue excludes cancelled and refunded orders.
select
    orders.order_id                                  as order_id,
    orders.customer_id                               as customer_id,
    orders.product_id                                as product_id,
    orders.ordered_at                                as ordered_at,
    {{ local_date('orders.ordered_at') }}            as order_date,
    orders.status                                    as status,
    orders.quantity                                  as quantity,
    orders.amount                                    as amount,
    products.category                                as product_category,
    customers.country                                as customer_country,
    CAST(orders.status not in ('cancelled', 'refunded') AS Bool)   as is_revenue
from {{ ref('stg_pg_orders') }} as orders
left join {{ ref('stg_pg_products') }} as products
    on orders.product_id = products.product_id
left join {{ ref('stg_pg_customers') }} as customers
    on orders.customer_id = customers.customer_id
