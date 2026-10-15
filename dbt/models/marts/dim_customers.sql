{{ config(order_by='customer_id') }}

-- One row per customer with order history (revenue orders only).
with order_stats as (
    select
        customer_id,
        count()          as lifetime_orders,
        sum(amount)      as lifetime_revenue,
        min(order_date)  as first_order_date,
        max(order_date)  as last_order_date
    from {{ ref('fct_orders') }}
    where is_revenue
    group by customer_id
)

select
    customers.customer_id                       as customer_id,
    customers.customer_name                     as customer_name,
    customers.email                             as email,
    customers.country                           as country,
    customers.created_at                        as created_at,
    coalesce(order_stats.lifetime_orders, 0)    as lifetime_orders,
    coalesce(order_stats.lifetime_revenue, 0)   as lifetime_revenue,
    order_stats.first_order_date                as first_order_date,
    order_stats.last_order_date                 as last_order_date
from {{ ref('stg_pg_customers') }} as customers
left join order_stats
    on customers.customer_id = order_stats.customer_id
