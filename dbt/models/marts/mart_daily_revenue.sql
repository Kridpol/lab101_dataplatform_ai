{{ config(order_by='date_day') }}

-- One row per calendar day between the first and last order, no gaps.
with bounds as (
    select min(order_date) as first_day, max(order_date) as last_day
    from {{ ref('fct_orders') }}
),

spine as (
    select arrayJoin(
        arrayMap(i -> addDays(first_day, i), range(toUInt32(dateDiff('day', first_day, last_day) + 1)))
    ) as date_day
    from bounds
),

daily as (
    select
        order_date,
        count()                 as orders,
        uniqExact(customer_id)  as customers,
        sum(quantity)           as units,
        sum(amount)             as revenue
    from {{ ref('fct_orders') }}
    where is_revenue
    group by order_date
)

select
    spine.date_day                    as date_day,
    coalesce(daily.orders, 0)         as orders,
    coalesce(daily.customers, 0)      as customers,
    coalesce(daily.units, 0)          as units,
    coalesce(daily.revenue, 0)        as revenue
from spine
left join daily
    on spine.date_day = daily.order_date
