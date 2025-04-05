{{
  config(
    materialized='view',
    schema='staging'
  )
}}

with trips_2023 as (
    select 
        ride_id,
        lower(rideable_type) as rideable_type,
        cast(started_at as timestamp) as start_time,
        cast(ended_at as timestamp) as end_time,
        start_station_name,
        start_station_id,
        end_station_name,
        end_station_id,
        start_lat,
        start_lng,
        end_lat,
        end_lng,
        lower(member_casual) as member_casual,
        timestamp_diff(cast(ended_at as timestamp), cast(started_at as timestamp), minute) as trip_duration_minutes,
        round(
            6371 * 2 * asin(
                sqrt(
                    power(sin((end_lat - start_lat) * acos(-1) / 360), 2) + 
                    cos(start_lat * acos(-1) / 180) * 
                    cos(end_lat * acos(-1) / 180) * 
                    power(sin((end_lng - start_lng) * acos(-1) / 360), 2)
                )
            ), 2
        ) as trip_distance_km,
        '2023' as year
    from {{ source('zoomcamp_project', 'citibike_2023_partitioned') }}
    where ride_id is not null
),

trips_2024 as (
    select 
        ride_id,
        lower(rideable_type) as rideable_type,
        cast(started_at as timestamp) as start_time,
        cast(ended_at as timestamp) as end_time,
        start_station_name,
        start_station_id,
        end_station_name,
        end_station_id,
        start_lat,
        start_lng,
        end_lat,
        end_lng,
        lower(member_casual) as member_casual,
        timestamp_diff(cast(ended_at as timestamp), cast(started_at as timestamp), minute) as trip_duration_minutes,
        round(
            6371 * 2 * asin(
                sqrt(
                    power(sin((end_lat - start_lat) * acos(-1) / 360), 2) + 
                    cos(start_lat * acos(-1) / 180) * 
                    cos(end_lat * acos(-1) / 180) * 
                    power(sin((end_lng - start_lng) * acos(-1) / 360), 2)
                )
            ), 2
        ) as trip_distance_km,
        '2024' as year
    from {{ source('zoomcamp_project', 'citibike_2024_partitioned') }}
    where ride_id is not null
)

select 
    ride_id,
    rideable_type,
    start_time,
    end_time,
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
    year
from trips_2023
union all
select 
    ride_id,
    rideable_type,
    start_time,
    end_time,
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
    year
from trips_2024