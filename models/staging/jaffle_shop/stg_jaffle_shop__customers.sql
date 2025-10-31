with

base_customers as (

    select * from {{ source("jaffle_shop","customers") }}

),

transformed_customers as (

    select 

        id as customer_id,
        last_name as surname,
        first_name as givenname,
        first_name || ' ' || last_name as full_name 

    from base_customers

)

select * from transformed_customers