with trips_2023 as (
    select 
        trip_id,
        cast(start_time as timestamp) as start_time,
        cast(end_time as timestamp) as end_time,
        start_station_id,
        end_station_id,
        lower(user_type) as user_type,
        timestamp_diff(end_time, start_time, minute) as trip_duration_minutes,
        '2023' as year
    from {{ source('citibike_2023', 'citibike_2023') }}
    where trip_id is not null 
      and start_time is not null 
      and end_time is not null
),

trips_2024 as (
    select 
        trip_id,
        cast(start_time as timestamp) as start_time,
        cast(end_time as timestamp) as end_time,
        start_station_id,
        end_station_id,
        lower(user_type) as user_type,
        timestamp_diff(end_time, start_time, minute) as trip_duration_minutes,
        '2024' as year
    from {{ source('citibike_2024', 'citibike_2024') }}
    where trip_id is not null 
      and start_time is not null 
      and end_time is not null
),

combined as (
    select * from trips_2023
    union all
    select * from trips_2024
)

select 
    trip_id,
    start_time,
    end_time,
    start_station_id,
    end_station_id,
    user_type,
    trip_duration_minutes,
    year
from combined;
