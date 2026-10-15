{{ config(order_by='product_id') }}

-- One row per product with sales from revenue orders.
with sales as (
    select
        product_id,
        sum(quantity)  as units_sold,
        sum(amount)    as revenue
    from {{ ref('fct_orders') }}
    where is_revenue
    group by product_id
)

select
    products.product_id                as product_id,
    products.product_name              as product_name,
    products.category                  as category,
    products.price                     as price,
    coalesce(sales.units_sold, 0)      as units_sold,
    coalesce(sales.revenue, 0)         as revenue
from {{ ref('stg_pg_products') }} as products
left join sales
    on products.product_id = sales.product_id
