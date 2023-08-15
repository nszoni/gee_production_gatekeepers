{% macro clone_from_to(from, to) %}

    {% set sql -%}
        create database if not exists {{ to }} clone {{ from }};
    {%- endset %}

    {{ dbt_utils.log_info("Cloning tables/views from database [" ~ from ~ "] into target database [" ~ to ~ "]") }}

    {% do run_query(sql) %}

    {{ dbt_utils.log_info("Cloned tables/views from database [" ~ from ~ "] into target database [" ~ to ~ "]") }}

{% endmacro %}


{% macro destroy_to_env(to) %}

    {% set sql -%}
        drop database if exists {{ to }} cascade;
    {%- endset %}

    {{ dbt_utils.log_info("Dropping tables/views in target database [" ~ to ~ "]") }}

    {% do run_query(sql) %}

    {{ dbt_utils.log_info("Dropped tables/views in target database [" ~ to ~ "]") }}

{% endmacro %}

{% macro zero_copy_clone_pre_prod(from, to) %}
{#-
This macro destroys your current preprod environment, and recreates it by cloning from prod.

To run it:
    $ dbt run-operation zero_copy_clone_pre_prod --args '{from: preprod, to: production}'

-#}
    {% if target.name == 'preprod' %}

    {{ destroy_to_env(to) }}

    {{ clone_from_to(from, to) }}

    {% else %}

    {{ dbt_utils.log_info("No-op: your current target is " ~ target.name ~ ". This macro only works for a default target.") }}

    {% endif %}

{% endmacro %}