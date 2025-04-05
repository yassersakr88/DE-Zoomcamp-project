-- tests/quality/stg_citibike_trips.sql
SELECT * FROM {{ ref('stg_citibike_trips') }}
WHERE 
  ride_id IS NULL
  OR start_time IS NULL
  OR end_time IS NULL
  OR trip_duration_minutes <= 0
  OR trip_distance_km <= 0