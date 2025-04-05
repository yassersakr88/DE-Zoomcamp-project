-- models/mart/rider_behavior.sql
{{
  config(
    materialized='incremental',
    partition_by={'field': 'started_at', 'data_type': 'date'},
    cluster_by=['rider_type', 'month']
  )
}}

SELECT
  rider_type,
  EXTRACT(YEAR FROM started_at) AS year,
  EXTRACT(MONTH FROM started_at) AS month,
  FORMAT_DATE('%B', DATE(started_at)) AS month_name,
  EXTRACT(DAYOFWEEK FROM started_at) AS day_of_week,
  FORMAT_DATE('%A', DATE(started_at)) AS weekday_name,
  EXTRACT(HOUR FROM started_at) AS hour_of_day,
  COUNT(DISTINCT ride_id) AS trip_count,
  AVG(duration_minutes) AS avg_duration,
  APPROX_QUANTILES(duration_minutes, 100)[OFFSET(50)] AS median_duration,
  AVG(distance_km) AS avg_distance_km,
  APPROX_QUANTILES(distance_km, 100)[OFFSET(50)] AS median_distance_km,
  COUNT(DISTINCT start_station_id) AS unique_start_stations,
  COUNT(DISTINCT end_station_id) AS unique_end_stations
FROM {{ ref('fct_citibike_trips') }}
WHERE 
  duration_minutes BETWEEN {{ var('min_trip_duration', 1) }} 
    AND {{ var('max_trip_duration', 1440) }}
  {% if is_incremental() %}
  AND started_at >= (SELECT MAX(started_at) FROM {{ this }})
  {% endif %}
GROUP BY 1, 2, 3, 4, 5, 6, 7