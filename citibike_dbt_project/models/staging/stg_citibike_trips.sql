-- models/staging/stg_citibike_trips.sql
{{
  config(
    materialized='view'
  )
}}

SELECT
  ride_id,
  CAST(started_at AS TIMESTAMP) AS started_at,
  CAST(ended_at AS TIMESTAMP) AS ended_at,
  -- Calculate duration in minutes from timestamps
  TIMESTAMP_DIFF(
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', ended_at),
    PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', started_at),
    MINUTE
  ) AS duration_minutes,
  start_station_id,
  start_station_name,
  SAFE_CAST(start_lng AS FLOAT64) AS start_lng,
  SAFE_CAST(start_lat AS FLOAT64) AS start_lat,
  SAFE_CAST(end_lng AS FLOAT64) AS end_lng,
  SAFE_CAST(end_lat AS FLOAT64) AS end_lat,
  end_station_id,
  end_station_name,
  member_casual AS rider_type
FROM {{ source('citibike', 'citibike_trips') }}