{% test valid_trip_duration(model, column_name, min_value=1, max_value=1440, allow_null=false) %}
SELECT
    {{ column_name }}
FROM
    {{ model }}
WHERE
    ({{ column_name }} < {{ min_value }} OR {{ column_name }} > {{ max_value }})
    {% if not allow_null %}
    OR {{ column_name }} IS NULL
    {% endif %}
{% endtest %}