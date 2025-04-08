-- models/mart/citibike_metrics.sql

SELECT
  rider_type,
  EXTRACT(YEAR FROM started_at) AS year,
  COUNT(DISTINCT ride_id) AS total_trips,
  AVG(duration_minutes) AS avg_duration_minutes,
  APPROX_QUANTILES(duration_minutes, 100)[OFFSET(50)] AS median_duration_minutes,
  AVG(distance_km) AS avg_distance_km,
  APPROX_QUANTILES(distance_km, 100)[OFFSET(50)] AS median_distance_km,
  COUNT(DISTINCT start_station_id) AS unique_start_stations,
  COUNT(DISTINCT end_station_id) AS unique_end_stations
FROM {{ ref('fct_citibike_trips') }}
WHERE duration_minutes BETWEEN 1 AND 1440
GROUP BY rider_type, year
