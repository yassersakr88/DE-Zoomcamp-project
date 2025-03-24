with trips_2023 as (
    select 
        trip_id,
        start_time,
        end_time,
        start_station_id,
        end_station_id,
        user_type,
        '2023' as year
    from {{ source('citibike_2023', 'citibike_2023') }}
),

trips_2024 as (
    select 
        trip_id,
        start_time,
        end_time,
        start_station_id,
        end_station_id,
        user_type,
        '2024' as year
    from {{ source('citibike_2024', 'citibike_2024') }}
),

citibike_combined as (
    select * from trips_2023
    union all
    select * from trips_2024
)

select * from citibike_combined;