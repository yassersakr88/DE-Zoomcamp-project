{{
  config(
    materialized='table',
    alias='dim_stations',
    unique_key='station_id'
  )
}}

WITH station_data AS (
  SELECT
    start_station_id AS station_id,
    start_station_name AS station_name
  FROM {{ ref('stg_citibike_trips') }}
  WHERE start_station_id IS NOT NULL
  
  UNION DISTINCT
  
  SELECT
    end_station_id AS station_id,
    end_station_name AS station_name
  FROM {{ ref('stg_citibike_trips') }}
  WHERE end_station_id IS NOT NULL
)

SELECT
  station_id,
  ANY_VALUE(station_name) AS station_name,
  CURRENT_TIMESTAMP() AS dbt_updated_at
FROM station_data
GROUP BY station_id