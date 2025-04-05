-- models/core/dim_stations.sql
{{
  config(
    materialized='table',
    schema='core'
  )
}}

WITH station_starts AS (
  SELECT
    start_station_id AS station_id,
    start_station_name AS station_name,
    start_lat AS latitude,
    start_lng AS longitude,
    COUNT(*) AS trip_count_start,
    'start' AS station_type
  FROM {{ ref('stg_citibike_trips') }}
  GROUP BY 1, 2, 3, 4
),

station_ends AS (
  SELECT
    end_station_id AS station_id,
    end_station_name AS station_name,
    end_lat AS latitude,
    end_lng AS longitude,
    COUNT(*) AS trip_count_end,
    'end' AS station_type
  FROM {{ ref('stg_citibike_trips') }}
  GROUP BY 1, 2, 3, 4
)

SELECT
  COALESCE(s.station_id, e.station_id) AS station_id,
  COALESCE(s.station_name, e.station_name) AS station_name,
  COALESCE(s.latitude, e.latitude) AS latitude,
  COALESCE(s.longitude, e.longitude) AS longitude,
  COALESCE(s.trip_count_start, 0) AS trip_count_start,
  COALESCE(e.trip_count_end, 0) AS trip_count_end,
  (COALESCE(s.trip_count_start, 0) + (COALESCE(e.trip_count_end, 0)) AS total_trip_count
FROM station_starts s
FULL OUTER JOIN station_ends e
  ON s.station_id = e.station_id