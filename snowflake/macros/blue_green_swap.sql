{#
    Swaps preprod with production database
    $ dbt run-operation blue_green_swap --args '{"source_db": "preprod", "target_db": "production"}'
#}

{% macro blue_green_swap(source_db, target_db) %}

    {%- if target.name == "preprod" -%}

        {% set sql = "alter database " ~ source_db ~ " swap with " ~ target_db -%}
        {% do run_query(sql) %}
        {% do log("Successfully swapped [" ~ source_db ~ "] with [" ~ target_db ~ "]!", info=True) %}

    {%- else -%}
        {{ log(target.name ~" is not supported for swapping", info=True) }}
    {%- endif -%}

{% endmacro %}