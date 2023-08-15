-- Macro to override ref and to render identifiers without a database so views can still work after swapping
{% macro ref(model_name) %}

  {% do return(builtins.ref(model_name).include(database=false)) %}

{% endmacro %}