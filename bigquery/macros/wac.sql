{% macro collect_tables(tags_to_clone) %}

    {% set tables = [] %}

    {% for model in graph.nodes.values() %}

        {% for tag in model.tags %}

            {%- if tag in tags_to_clone and model.config.materialized in ('table', 'incremental') %}

                {% do tables.append(model.name) %}

            {%- endif %}

        {% endfor %}

    {% endfor %}

    {{ log("Tables to clone: " ~ tables, info=True) }}

    {{ return(tables) }}

{% endmacro %}

{% macro clone_tables(tables, preprod_dataset, prod_dataset) %}

    -- iterate through all the tables and clone them over to prod
    {% for item in tables %}

        -- log the process
        {{ log(target.project ~ '.' ~ preprod_dataset ~ '.' ~ item ~ ' -> ' ~ target.project ~ '.' ~ prod_dataset ~ '.' ~ item, info=True) }}

        {% call statement(name, fetch_result=true) %}

            -- copy from single analytics_staging schema but distribute to different schemas in prod
            create or replace table
            {{ target.project }}.{{ prod_dataset }}.{{ item }}
            clone {{ target.project }}.{{ preprod_dataset }}.{{ item }};

        {% endcall %}

    {% endfor %}

{% endmacro %}

{% macro write_audit_clone(tags_to_clone, preprod_dataset, prod_dataset) %}

    {#
        EXPECTED BEHAVIOR:
        1. Collects all table desired to be cloned based on tags
        2. Clones tables from preprod to prod

        $ dbt run-operation write_audit_clone --args '{"tags_to_clone": ["mart"], "preprod_dataset": "preprod", "prod_dataset": "production"}'
    #}

    {% if target.dataset == 'preprod' %}

        {{ log("Gathering " ~ tags_to_clone ~ " to clone from " ~ preprod_dataset, info=True) }}

        {% set tables = collect_tables(tags_to_clone) %}

        {{ log("Cloning " ~ tags_to_clone ~ " layer(s) from [" ~ preprod_dataset ~ "] to [" ~ prod_dataset ~ "].", info=True) }}

        {{ clone_tables(tables, preprod_dataset, prod_dataset) }}

        {{ log("Tables cloned successfully from [" ~ preprod_dataset ~ "] to [" ~ prod_dataset ~ "]!", info=True) }}

    {% else %}

        {{ log("This macro is only meant to be run on preprod dataset.", info=True) }}

    {% endif %}

{% endmacro %}
