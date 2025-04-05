{% test valid_geopoint(model, latitude_col, longitude_col) %}
SELECT
    {{ latitude_col }},
    {{ longitude_col }}
FROM
    {{ model }}
WHERE
    {{ latitude_col }} IS NOT NULL
    AND {{ longitude_col }} IS NOT NULL
    AND ({{ latitude_col }} NOT BETWEEN -90 AND 90
         OR {{ longitude_col }} NOT BETWEEN -180 AND 180)
{% endtest %}