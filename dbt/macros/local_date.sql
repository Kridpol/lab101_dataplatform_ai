{# Calendar day of a UTC timestamp in the business timezone (TIMEZONE in .env). #}
{% macro local_date(column) -%}
    toDate({{ column }}, '{{ env_var("TIMEZONE") }}')
{%- endmacro %}
