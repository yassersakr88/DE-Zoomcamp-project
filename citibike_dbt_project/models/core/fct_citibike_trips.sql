{{
  config(
    materialized='incremental',
    partition_by={
      'field': 'started_at', 
      'data_type': 'timestamp',
      'granularity': 'day'
    },
    cluster_by=['start_station_id', 'rider_type']
  )
}}

SELECT
  t.ride_id,
  t.started_at,
  t.ended_at,
  t.duration_minutes,
  t.start_station_id,
  s.station_name AS start_station_name,
  t.end_station_id,  -- Make sure to include this field
  s2.station_name AS end_station_name,  -- Add the name for end station, if necessary
  t.rider_type,
  EXTRACT(HOUR FROM t.started_at) AS hour_of_day,
  FORMAT_DATE('%A', DATE(t.started_at)) AS day_of_week,
  111.045 * ST_DISTANCE(
    ST_GEOGPOINT(t.start_lng, t.start_lat),
    ST_GEOGPOINT(t.end_lng, t.end_lat)
  ) AS distance_km
FROM `citibike-zoomcamp-project`.`zoomcamp_project_staging`.`stg_citibike_trips` t
LEFT JOIN `citibike-zoomcamp-project`.`zoomcamp_project_analytics`.`dim_stations` s
  ON t.start_station_id = s.station_id
LEFT JOIN `citibike-zoomcamp-project`.`zoomcamp_project_analytics`.`dim_stations` s2
  ON t.end_station_id = s2.station_id
WHERE t.started_at IS NOT NULL
  AND t.ended_at IS NOT NULL
  AND t.started_at < t.ended_at
