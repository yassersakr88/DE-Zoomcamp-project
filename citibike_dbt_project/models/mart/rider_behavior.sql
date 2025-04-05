-- models/marts/rider_behavior.sql
{{
  config(
    materialized='table'
  )
}}

SELECT
  member_casual AS rider_type,
  AVG(trip_duration_minutes) AS avg_duration_min,
  AVG(trip_distance_km) AS avg_distance_km,
  COUNT(*) AS trip_count,
  COUNT(DISTINCT ride_id) AS unique_trips,
  EXTRACT(MONTH FROM started_at) AS month
FROM {{ ref('fct_citibike_trips') }}
WHERE is_valid_trip
GROUP BY 1, 6