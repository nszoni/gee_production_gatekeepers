{#
    In case of WAP, we need to make sure then when publishing (P),
    we still use the preprod dataset for references, but production
    for target output.
#}

{% macro ref(table_name) %}

    {% if target.name == 'prod' and var('audit', false) == false %}

        {% set parentdataset = 'preprod' %}
        {% set path = target.project ~ '.' ~ parentdataset ~ '.' ~ table_name %}
        {% do return(path) %}

    {% else %}

        {% do return(builtins.ref(table_name)) %}

    {% endif %}
    
{% endmacro %}