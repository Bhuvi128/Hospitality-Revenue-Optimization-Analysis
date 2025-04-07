/*
===============================================================================================================================================================================
===============================================================================================================================================================================
								-- Hospitality Revenue Optimization --
===============================================================================================================================================================================
===============================================================================================================================================================================

*/

-- Problem Statement:
/*
AtliQ Grands owns multiple five-star hotels across India. They have been in the hospitality industry for the past 20 years. 
Due to strategic moves from other competitors and ineffective decision-making in management, AtliQ Grands are losing its market share 
and revenue in the luxury/business hotels category. As a strategic move, the managing director of AtliQ Grands wanted to 
incorporate “Business and Data Intelligence” to regain their market share and revenue. However, they do not have an in-house data analytics
team to provide them with these insights.
Their revenue management team had decided to hire a 3rd party service provider to provide them with insights from their historical data.
*/

use atliq_hospitality_db;

/*
===================================================================================================================================================
----------------------------------------  Data Preparation and cleaning  --------------------------------------------------------------------------
===================================================================================================================================================
*/


-- Are there duplicate entries in the fact_bookings table?

select * from
(select *, count(*) over(partition by booking_id) as dup_count 
from fact_bookings) dup_check
where dup_count > 1;  -- using window function, extracted duplicate entries in fact bookings table. There is no duplicates.

-- Investigate duplicates in fact_aggregated_bookings — do they have distinct features?

select * from
(select *, count(*) over(partition by property_id) as dup_count
from fact_aggregated_bookings) dup_check
where dup_count > 1; -- There is duplicates in fact aggregated bookings table, but every duplicates have different features.

-- Confirm if dim_hotels contains any duplicate property_id values.

select * from
(select *, count(*) over(partition by property_id) dup_count
from dim_hotels) dup_check
where dup_count > 1; -- There is no duplicate entries based on property_id in dim hotels table

-- Check for duplicates in dim_rooms — are any found?

select * from
(select *, count(*) over(partition by room_id) dup_count
from dim_rooms) dup_check
where dup_count > 1; -- No duplicates

-- Are there duplicate entries in the dim_date table?

select * from
(select *, count(*) over(partition by date_d) dup_count
from dim_date) dup_check
where dup_count > 1; -- No duplicates

/* 2. Check for data types */

-- Are there any invalid data types in fact_bookings?
describe fact_bookings; -- No invalid data types

-- Verify if data types in fact_aggregated_bookings are valid.
describe fact_aggregated_bookings; -- Data types in fact aggregated bookings table are valid;

-- Verify if data types in dim_hotels are valid.
describe dim_hotels; -- Data types are valid in dim hotels table

-- Are there any invalid data types in dim_rooms?
describe dim_rooms; -- Valid data types

-- Are there any invalid data types in dim_date?
describe dim_date; -- valid data types

/*
=======================================================================================================================================================
------------------------------------------------------- Exploratory Data analysis ---------------------------------------------------------------------
=======================================================================================================================================================
*/

/* How many total bookings exist in the fact_bookings table? */

select count(*) total_bookings  
from fact_bookings;

/* How are bookings distributed among different booking statuses? */

select booking_status, count(*) total_bookings
from fact_bookings
group by booking_status;

/* Retreive revenue generated from fact bookings to calculate summary statistics and its distribution analysis */

select revenue_generated from fact_bookings;

/* Retreive revenue realized from fact bookings to calculate summary statistics and its distribution analysis */

select revenue_realized from fact_bookings;

/* Retreive revenue generated and realized and check relationship between them */

select revenue_generated, revenue_realized from fact_bookings;

/* Does booking status impact the difference between revenue generated and revenue realized? */

select booking_status, revenue_generated, revenue_realized
from fact_bookings;  

/* How bookings are distributed among room class */

select dr.room_class, count(*) total_bookings
from dim_rooms dr right join fact_bookings fb
on dr.room_id = fb.room_category
group by dr.room_class;

/* What is the revenue generated and realized for each room class? */

select dr.room_class, fb.revenue_generated, fb.revenue_realized
from fact_bookings fb left join dim_rooms dr
on fb.room_category = dr.room_id; 

/* For cancelled bookings, what is the revenue generated and realized for each room class? */

select dr.room_class, booking_status, revenue_generated, revenue_realized
from
(select * from fact_bookings
where booking_status = 'Cancelled') fb left join dim_rooms dr
on fb.room_category = dr.room_id; 

/* How bookings are distributed across property category */

select dh.category, count(*) total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.category
order by total_bookings desc;

/* What is the revenue generated and realized by property category and booking status? */

select dh.category, fb.booking_status, fb.revenue_generated, fb.revenue_realized
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id; 

/* How the bookings distributed across properties? */

select dh.property_name, count(*) total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.property_name
order by total_bookings desc;

/* What is the revenue generated and realized by property name and booking status? */

select dh.property_name, fb.booking_status, fb.revenue_generated, fb.revenue_realized 
from dim_hotels dh right join fact_bookings fb
on dh.property_id = fb.property_id; 

/* How the bookings distributed across cities? */

select dh.city, count(*) total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.city
order by total_bookings desc;

/* What is the revenue generated and realized by property city and booking status? */

select dh.city, fb.booking_status, fb.revenue_generated, fb.revenue_realized
from dim_hotels dh right join fact_bookings fb
on dh.property_id = fb.property_id;

/* How bookings distributed across different months */

select month(booking_date) booking_month, count(*) total_bookings
from fact_bookings
group by booking_month
order by booking_month;

/* what is the revenue generated and realized by booking month? */

select month(booking_date) booking_month, booking_status, revenue_generated, revenue_realized
from fact_bookings
order by booking_month;

/* How bookings distributed among number of guests */

select no_guests, count(*) total_bookings
from fact_bookings
group by no_guests
order by no_guests;

/* Do no of guests impact on revenue generated and realized */

select no_guests, booking_status, revenue_generated, revenue_realized
from fact_bookings
order by no_guests;

/* How bookings are distributed among booking platforms */

select booking_platform, count(*) total_bookings
from fact_bookings
group by booking_platform
order by total_bookings;

/* Do booking platforms impact revenue loss from cancellations */

with platform_revenue as (
select booking_platform, booking_status, revenue_generated, revenue_realized
from fact_bookings
)
select * from platform_revenue
where booking_status = 'Cancelled';

/* How much ratings are given for most of the bookings */

select ratings_given, count(*) total_bookings
from fact_bookings
group by ratings_given
order by ratings_given;


/* Do ratings impact from cancellations */

select ratings_given, booking_status, revenue_generated,
revenue_realized
from fact_bookings
where booking_status = 'Cancelled'
order by ratings_given;

/* Do 0 ratings apply only to cancelled bookings, or also to checked-out and no-show bookings */

select ratings_given, booking_status, revenue_generated,
revenue_realized
from fact_bookings
where booking_status != 'Cancelled'
order by ratings_given;

/* What is the typical stay duration for most bookings */

select datediff(checkout_date, check_in_date) stay_duration, 
count(*) total_bookings
from fact_bookings
group by stay_duration
order by stay_duration;

/* What is the typical stay duration for cancelled bookings */

select datediff(checkout_date, check_in_date) stay_duration, 
booking_status, revenue_generated, revenue_realized
from fact_bookings
where booking_status = 'Cancelled'
order by stay_duration;

/* Is cancellations happening more in weekend or weekday */

select dd.day_type, 
sum(case when fb.booking_status = 'Cancelled' then 1 else 0 end) cancelled_bookings,
sum(case when fb.booking_status != 'Cancelled' then 1 else 0 end) successfull_bookings
from fact_bookings fb left join dim_date dd
on fb.check_in_date = dd.date_d
group by dd.day_type
order by cancelled_bookings desc;

/* Is specific week no have higher or lower successful and cancelled bookings */

select dd.week_no, 
sum(case when fb.booking_status = 'Cancelled' then 1 else 0 end) cancelled_bookings,
sum(case when fb.booking_status != 'Cancelled' then 1 else 0 end) successfull_bookings
from fact_bookings fb left join dim_date dd
on fb.check_in_date = dd.date_d
group by dd.week_no
order by cancelled_bookings, successfull_bookings;

/* How much successful bookings and capacity in particular check in date */

select check_in_date, 
sum(successful_bookings) as total_successful_bookings,
sum(capacity) as total_capacity
from fact_aggregated_bookings
group by check_in_date
order by check_in_date;

/* How much successful bookings and capacity in particular check in date and particular room class */

select fa.check_in_date, dr.room_class,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity
from fact_aggregated_bookings fa
left join dim_rooms dr
on fa.room_category = dr.room_id
group by fa.check_in_date, dr.room_class
order by fa.check_in_date;

/* How much successful bookings and capacity in particular check in date and particular property city */

select fa.check_in_date, dh.city,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity
from fact_aggregated_bookings fa
left join dim_hotels dh
on fa.property_id = dh.property_id
group by fa.check_in_date, dh.city
order by fa.check_in_date;

/* How much successful bookings and capacity in particular check in date and particular property */

select fa.check_in_date, dh.property_name,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity
from fact_aggregated_bookings fa
left join dim_hotels dh
on fa.property_id = dh.property_id
group by fa.check_in_date, dh.property_name
order by fa.check_in_date;

/* How much successful bookings and capacity in particular check in date and particular property category */

select fa.check_in_date, dh.category,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity
from fact_aggregated_bookings fa
left join dim_hotels dh
on fa.property_id = dh.property_id
group by fa.check_in_date, dh.category
order by fa.check_in_date;

/* How much successful bookings and capacity in particular check in date and particular month and year */

select fa.check_in_date, dd.mmm_yy,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity
from fact_aggregated_bookings fa
left join dim_date dd
on fa.check_in_date = dd.date_d
group by fa.check_in_date, dd.mmm_yy
order by fa.check_in_date;

/* How much successful bookings and capacity in particular check in date and particular week no */

select fa.check_in_date, dd.week_no,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity
from fact_aggregated_bookings fa
left join dim_date dd
on fa.check_in_date = dd.date_d
group by fa.check_in_date, dd.week_no
order by fa.check_in_date;

/* How much successful bookings and capacity in particular check in date and particular day type */

select fa.check_in_date, dd.day_type,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity
from fact_aggregated_bookings fa
left join dim_date dd
on fa.check_in_date = dd.date_d
group by fa.check_in_date, dd.day_type
order by fa.check_in_date;
