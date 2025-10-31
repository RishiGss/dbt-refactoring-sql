with

base_payments as (

    select * from {{ source("stripe","payments") }}

),

transformed_payments as (

    select

        id as payment_id,
        orderid as order_id,
        paymentmethod as payment_method,
        status as payment_status,
        round(amount/100.0,2) as payment_amount,
        created as payment_date

    from base_payments

)

select * from transformed_payments