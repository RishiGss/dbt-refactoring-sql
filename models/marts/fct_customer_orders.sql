with

customers as (
    
    select * from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

    select * from {{ ref('int_orders') }}

),

customer_order_list as (

    select
        customer_id,
        array_distinct(collect_list(order_id)) as customer_order_ids
    from orders
    group by customer_id

),

customer_orders as (

    select 

        orders.*,
        customers.full_name,
        customers.surname,
        customers.givenname,
        customer_order_ids,

        --- customer level aggregations
        min(order_date) over(
            partition by orders.customer_id
        ) as customer_first_order_date,

        min(valid_order_date) over(
            partition by orders.customer_id
        ) as customer_first_non_returned_order_date,
        
        max(valid_order_date) over(
            partition by orders.customer_id
        ) as customer_most_recent_non_returned_order_date,
        
        count(*) over(
            partition by orders.customer_id
        ) as customer_order_count,
        
        
        sum(nvl2(orders.valid_order_date, 1, 0)) over(
            partition by orders.customer_id
        ) as customer_non_returned_order_count,
        
        sum(nvl2(orders.valid_order_date,
            orders.order_value_dollars,
            0) 
        ) over(
            partition by orders.customer_id
        ) as customer_total_lifetime_value
        
        /*array_agg(distinct orders.order_id) over(
            partition by orders.customer_id
        ) as customer_order_ids*/


    from orders

    inner join customers
    on orders.customer_id = customers.customer_id

    left join customer_order_list 
    on orders.customer_id = customer_order_list.customer_id

),

add_avg_order_values (

    select 
    
    *,
    customer_total_lifetime_value / customer_non_returned_order_count as customer_avg_non_returned_order_value

    from customer_orders

),

-- Final CTE

final as (

    select 

        order_id,
        customer_id,
        surname,
        givenname,
        customer_first_order_date as first_order_date,
        customer_order_count as order_count,
        customer_total_lifetime_value as total_lifetime_value,
        customer_avg_non_returned_order_value as avg_non_returned_order_value,
        order_value_dollars,
        order_status,
        payment_status

    from add_avg_order_values

)

-- Simple Select Statement

select * from final