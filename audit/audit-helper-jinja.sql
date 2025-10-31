{# in dbt Develop #}

{% set old_etl_relation=adapter.get_relation(
database=target.database,
schema="modular_refactored_sql",
identifier="customer_orders"
) -%}

{% set dbt_relation=ref("fct_customer_orders") %}

{% if execute %}

{{ audit_helper.compare_relations(
a_relation=old_etl_relation,
b_relation=dbt_relation,
primary_key="order_id"
) }}

{% endif %}