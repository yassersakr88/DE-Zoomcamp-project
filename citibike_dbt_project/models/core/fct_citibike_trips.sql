{{
  config(
    materialized='table',
    schema='core'
  )
}}

with source_trips as (
    select * from {{ ref('stg_citibike_trips') }}
),

cleaned_trips as (
    select
        ride_id,
        rideable_type,
        start_time as started_at,
        end_time as ended_at,
        start_station_name,
        start_station_id,
        end_station_name,
        end_station_id,
        start_lat,
        start_lng,
        end_lat,
        end_lng,
        member_casual,
        trip_duration_minutes,
        trip_distance_km,
        year,
        -- Additional data quality checks
        case
            when trip_duration_minutes <= 0 then false
            when trip_distance_km <= 0 then false
            when start_lat is null or start_lng is null then false
            when end_lat is null or end_lng is null then false
            else true
        end as is_valid_trip
    from source_trips
    where 
        start_time is not null
        and end_time is not null
        and start_time < end_time
)

select
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    start_station_name,
    start_station_id,
    end_station_name,
    end_station_id,
    start_lat,
    start_lng,
    end_lat,
    end_lng,
    member_casual,
    trip_duration_minutes,
    trip_distance_km,
    year,
    is_valid_trip,
    -- Derived metrics
    round(trip_distance_km / nullif(trip_duration_minutes/60, 0), 2) as avg_speed_kmh,
    extract(dayofweek from started_at) as day_of_week,
    extract(hour from started_at) as hour_of_day
from cleaned_trips