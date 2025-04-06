SELECT
  fct.started_at,
  fct.rider_type,
  EXTRACT(YEAR FROM fct.started_at) AS year,
  EXTRACT(MONTH FROM fct.started_at) AS month,
  FORMAT_DATE('%B', DATE(fct.started_at)) AS month_name,
  EXTRACT(DAYOFWEEK FROM fct.started_at) AS day_of_week,
  FORMAT_DATE('%A', DATE(fct.started_at)) AS weekday_name,
  EXTRACT(HOUR FROM fct.started_at) AS hour_of_day,
  COUNT(DISTINCT fct.ride_id) AS trip_count,
  AVG(fct.duration_minutes) AS avg_duration,
  APPROX_QUANTILES(fct.duration_minutes, 100)[OFFSET(50)] AS median_duration,
  AVG(COALESCE(fct.distance_km, 0)) AS avg_distance_km,
  APPROX_QUANTILES(COALESCE(fct.distance_km, 0), 100)[OFFSET(50)] AS median_distance_km,
  COUNT(DISTINCT fct.start_station_id) AS unique_start_stations,
  COUNT(DISTINCT fct.end_station_id) AS unique_end_stations
FROM `citibike-zoomcamp-project`.`zoomcamp_project_analytics`.`fct_citibike_trips` AS fct
WHERE 
  fct.duration_minutes BETWEEN 1 AND 1440
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8