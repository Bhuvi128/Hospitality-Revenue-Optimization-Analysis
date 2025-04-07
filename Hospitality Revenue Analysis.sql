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
-----------------------------------------------------  Data Validation & Cleaning  ----------------------------------------------------------------
===================================================================================================================================================
*/

-- 1.1 Check for duplicates
select * from
(select *, count(*) over(partition by booking_id) as dup_count 
from fact_bookings) dup_check
where dup_count > 1;  

select * from
(select *, count(*) over(partition by property_id) as dup_count
from fact_aggregated_bookings) dup_check
where dup_count > 1; 

select * from
(select *, count(*) over(partition by property_id) as dup_count
from dim_hotels) dup_check
where dup_count > 1; 

select * from
(select *, count(*) over(partition by room_id) as dup_count
from dim_rooms) dup_check
where dup_count > 1; 

select * from
(select *, count(*) over(partition by date_d) as dup_count
from dim_date) dup_check
where dup_count > 1; 

-- 1.2 Validate data types
describe fact_bookings; 
describe fact_aggregated_bookings; 
describe dim_hotels;
describe dim_rooms;
describe dim_date;

/*
=======================================================================================================================================================
------------------------------------------------------- Exploratory Data analysis ---------------------------------------------------------------------
=======================================================================================================================================================
*/

-- 2.1 Overall Bookings
select count(*) as total_bookings  
from fact_bookings;

-- 2.2 Booking status distribution
select booking_status, count(*) as total_bookings
from fact_bookings
group by booking_status;

-- 2.3 Room class distribution
select dr.room_class, count(*) as total_bookings
from dim_rooms dr right join fact_bookings fb
on dr.room_id = fb.room_category
group by dr.room_class;

-- 2.4 Property category distribution
select dh.category, count(*) as total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.category
order by total_bookings desc;

-- 2.5 Property distribution
select dh.property_name, count(*) as total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.property_name
order by total_bookings desc;

-- 2.6 Property city distribution
select dh.city, count(*) as total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.city
order by total_bookings desc;

-- 2.7 Booking trends by month
select monthname(booking_date) booking_month, count(*) as total_bookings
from fact_bookings
group by booking_month
order by field(booking_month, 'April', 'May', 'June', 'July');

-- 2.8 Guest Count Distribution
select no_guests, count(*) as total_bookings
from fact_bookings
group by no_guests
order by no_guests;

-- 2.9 Booking Platform distribution
select booking_platform, count(*) as total_bookings
from fact_bookings
group by booking_platform
order by total_bookings;

-- 2.10 Ratings distribution
select ratings_given, count(*) as total_bookings
from fact_bookings
group by ratings_given
order by ratings_given;

-- 2.11 Stay Duration Trends
select datediff(checkout_date, check_in_date) as stay_duration, 
count(*) as total_bookings
from fact_bookings
group by stay_duration
order by stay_duration;

-- 2.12 City-wise Booking status
select dh.city, fb.booking_status, count(*) as total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.city, fb.booking_status
order by total_bookings;

-- 2.13 Platform-wise booking status
select booking_platform, booking_status,
count(*) as total_bookings
from fact_bookings
group by booking_platform, booking_status
order by total_bookings;

-- 2.14 Room class-wise booking status
select dr.room_class, fb.booking_status,
 count(*) as total_bookings
from dim_rooms dr right join fact_bookings fb
on dr.room_id = fb.room_category
group by dr.room_class, fb.booking_status
order by total_bookings;

-- 2.15 Property category-wise booking status
select dh.category, fb.booking_status,
count(*) as total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.category, fb.booking_status
order by total_bookings;

-- 2.16 Property-wise booking status
select dh.property_name, fb.booking_status,
 count(*) as total_bookings
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.property_name, fb.booking_status
order by total_bookings;

-- 2.17 Booking month-wise booking status
select monthname(booking_date) booking_month, booking_status,
count(*) as total_bookings
from fact_bookings
group by booking_month, booking_status
order by field(booking_month, 'April', 'May', 'June', 'July'), total_bookings;

-- 2.18 Guest count-wise booking status
select no_guests, booking_status,
count(*) as total_bookings
from fact_bookings
group by no_guests, booking_status
order by no_guests, total_bookings;

-- 2.19 Ratings-wise booking status
select ratings_given, booking_status,
count(*) as total_bookings
from fact_bookings
group by ratings_given, booking_status
order by ratings_given, total_bookings;

-- 2.20 Stay duration trends by booking status
select datediff(checkout_date, check_in_date) as stay_duration, 
booking_status,
count(*) as total_bookings
from fact_bookings
group by stay_duration, booking_status
order by stay_duration, total_bookings;

-- 2.21 City-wise Cancellation rate
select dh.city, count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.city
order by total_bookings;

-- 2.22 Platform-wise Cancellation rate
select booking_platform, count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings
group by booking_platform
order by total_bookings;

-- 2.23 Room class-wise cancellation rate
select dr.room_class, count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from dim_rooms dr right join fact_bookings fb
on dr.room_id = fb.room_category
group by dr.room_class
order by total_bookings;

-- 2.24 Property category-wise cancellation rate
select dh.category, count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.category
order by total_bookings;

-- 2.25 Property-wise cancellation rate
select dh.property_name, count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.property_name
order by total_bookings;

-- 2.26 Booking month wise cancellation rate
select monthname(booking_date) booking_month, count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings
group by booking_month
order by field(booking_month, 'April', 'May', 'June', 'July'), total_bookings;

-- 2.27 Guest count-wise cancellation rate
select no_guests, count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings
group by no_guests
order by no_guests, total_bookings;

-- 2.28 Ratings-wise cancellation rate
select ratings_given, count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings
group by ratings_given
order by ratings_given, total_bookings;

-- 2.29 Stay duration-wise cancellation rate
select datediff(checkout_date, check_in_date) as stay_duration, 
count(*) as total_bookings,
sum(case when booking_status = 'Cancelled' then 1 else 0 end) as cancelled_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings
group by stay_duration
order by stay_duration, total_bookings;

-- 2.30 Are cancellations happening more on weekends or weekdays?
select dd.day_type, 
sum(case when fb.booking_status = 'Cancelled' then 1 else 0 end) cancelled_bookings,
sum(case when fb.booking_status != 'Cancelled' then 1 else 0 end) successfull_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings fb left join dim_date dd
on fb.check_in_date = dd.date_d
group by dd.day_type
order by cancelled_bookings desc;

-- 2.31 Do specific weeks have higher or lower successful and cancelled bookings?
select dd.week_no, 
sum(case when fb.booking_status = 'Cancelled' then 1 else 0 end) cancelled_bookings,
sum(case when fb.booking_status != 'Cancelled' then 1 else 0 end) successfull_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings fb left join dim_date dd
on fb.check_in_date = dd.date_d
group by dd.week_no
order by cancelled_bookings desc;

-- 2.32 Check daily successful bookings vs hotel capacity
select check_in_date, 
sum(successful_bookings) as total_successful_bookings,
sum(capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings
group by check_in_date
order by check_in_date;

-- 2.33 Daily successful bookings vs capacity per room class
select fa.check_in_date, dr.room_class,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_rooms dr
on fa.room_category = dr.room_id
group by fa.check_in_date, dr.room_class
order by fa.check_in_date;

-- 2.34 Daily successful bookings vs capacity per city
select fa.check_in_date, dh.city,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_hotels dh
on fa.property_id = dh.property_id
group by fa.check_in_date, dh.city
order by fa.check_in_date;

-- 2.35 Daily successful bookings vs capacity per property
select fa.check_in_date, dh.property_name,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_hotels dh
on fa.property_id = dh.property_id
group by fa.check_in_date, dh.property_name
order by fa.check_in_date;

-- 2.36 Daily successful bookings vs capacity per property category
select fa.check_in_date, dh.category,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_hotels dh
on fa.property_id = dh.property_id
group by fa.check_in_date, dh.category
order by fa.check_in_date;

-- 2.37 Daily successful bookings vs capacity per month with year
select fa.check_in_date, dd.mmm_yy,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_date dd
on fa.check_in_date = dd.date_d
group by fa.check_in_date, dd.mmm_yy
order by fa.check_in_date;

-- 2.38 Daily successful bookings vs capacity per week
select fa.check_in_date, dd.week_no,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_date dd
on fa.check_in_date = dd.date_d
group by fa.check_in_date, dd.week_no
order by fa.check_in_date;

-- 2.39 Daily successful bookings vs capacity per day type
select fa.check_in_date, dd.day_type,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_date dd
on fa.check_in_date = dd.date_d
group by fa.check_in_date, dd.day_type
order by fa.check_in_date;


/*
=======================================================================================================================================================
------------------------------------------------------- Revenue Leakage & Optimization Insights -------------------------------------------------------
=======================================================================================================================================================
*/

-- 3.1 Calculate average revenue generated vs realized per booking status
select booking_status, 
count(*) as total_bookings, 
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(revenue_generated),2) as avg_revenue_generated, 
round(avg(revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings
group by booking_status
order by total_bookings;

-- 3.2 Calculate average revenue generated vs realized per room class
select dr.room_class, 
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(fb.revenue_generated),2) as avg_revenue_generated, 
round(avg(fb.revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings fb left join dim_rooms dr
on fb.room_category = dr.room_id
group by dr.room_class
order by total_bookings;

-- 3.3 Calculate average revenue generated vs realized per property category
select dh.category, 
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(fb.revenue_generated),2) as avg_revenue_generated, 
round(avg(fb.revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.category
order by total_bookings;

-- 3.4 Calculate average revenue generated vs realized per property
select dh.property_name, 
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(fb.revenue_generated),2) as avg_revenue_generated, 
round(avg(revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from dim_hotels dh right join fact_bookings fb
on dh.property_id = fb.property_id
group by dh.property_name
order by total_bookings;

-- 3.5 Calculate average revenue generated vs realized per property city
select dh.city, 
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(fb.revenue_generated),2) as avg_revenue_generated, 
round(avg(revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings fb left join dim_hotels dh
on fb.property_id = dh.property_id
group by dh.city
order by total_bookings;

-- 3.6 Calculate average revenue generated vs realized per booking month
select monthname(booking_date) booking_month,
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(revenue_generated),2) as avg_revenue_generated, 
round(avg(revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings
group by booking_month
order by field(booking_month, 'April', 'May', 'June', 'July');

-- 3.7 Calculate average revenue generated vs realized per number of guests
select no_guests, 
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(revenue_generated),2) as avg_revenue_generated, 
round(avg(revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings
group by no_guests
order by no_guests;

-- 3.8 Calculate average revenue generated vs realized per booking platform
select booking_platform, 
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(revenue_generated),2) as avg_revenue_generated, 
round(avg(revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings
group by booking_platform
order by total_bookings;

-- 3.9 Calculate average revenue generated vs realized per ratings
select ratings_given, 
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(revenue_generated),2) as avg_revenue_generated, 
round(avg(revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings
group by ratings_given
order by ratings_given;

-- 3.10 Calculate average revenue generated vs realized per stay duration
select datediff(checkout_date, check_in_date) as stay_duration, 
count(*) as total_bookings,
round(sum(revenue_generated),2) as total_revenue_generated, 
round(sum(revenue_realized),2) as total_revenue_realized,
round(avg(revenue_generated),2) as avg_revenue_generated, 
round(avg(revenue_realized),2) as avg_revenue_realized,
round(avg(revenue_generated - revenue_realized),2) as avg_revenue_loss_per_booking,
round(100 * (sum(revenue_generated) - sum(revenue_realized)) / sum(revenue_generated)) as revenue_loss_percent
from fact_bookings
group by stay_duration
order by stay_duration;
