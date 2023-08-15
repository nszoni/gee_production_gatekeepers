{#

This macro ensures the WAP (write-audit-pr). More on WAP: https://calogica.com/assets/wap_dbt_bigquery.pdf
Use audit: true in your run to enable WAP.
Omit audit var in the last stage of your build to publish to analytics db.

# runs in analytics_staging (pre-prod)
dbt seed --vars 'audit: true'
dbt run --vars 'audit: true'
dbt test --vars 'audit: true'

# when previous stages are done, run in analytics (production)
dbt run -s models/marts

#}

{% macro generate_schema_name_for_env(custom_schema_name=none) -%}

    {% set default_schema = target.schema %}
    
    {%- if target.name == "prod" and var("audit", false) == true -%}
        preprod
    {%- elif target.name == "prod" and var("audit", false) == false -%}
        production
    {%- else -%}
        {{ default_schema }}
    {%- endif -%}

{%- endmacro %}

{% macro generate_schema_name(schema_name, node) -%}
    {{ generate_schema_name_for_env(schema_name) }}
{%- endmacro %}