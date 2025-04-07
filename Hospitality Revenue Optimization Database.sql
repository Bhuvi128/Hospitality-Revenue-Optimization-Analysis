/* create database atliq_hospitality_db;    */

/*
USE atliq_hospitality_db;

create table dim_date (
date_d	date not null,
mmm_yy	varchar(20) not null,
week_no	int not null,
day_type varchar(50) not null,
primary key(date_d)
);

create table dim_hotels (
property_id	int unsigned not null,
property_name varchar(60) not null,	
category varchar(20) not null,	
city varchar(50) not null,
primary key(property_id)
);

create table dim_rooms (
room_id	varchar(10) not null,
room_class varchar(50) not null,
primary key(room_id)
);

create table fact_aggregated_bookings (
property_id	int unsigned not null,
check_in_date date not null,	
room_category varchar(10) not null,	
successful_bookings	int not null,
capacity int not null,
foreign key(property_id) references dim_hotels(property_id),
foreign key(check_in_date) references dim_date(date_d),
foreign key(room_category) references dim_rooms(room_id)
);

create table fact_bookings (
booking_id varchar(200) not null,	
property_id	int unsigned not null,
booking_date date not null,	
check_in_date date not null,	
checkout_date date not null,	
no_guests int not null,	
room_category varchar(10) not null, 	
booking_platform varchar(100) not null,	
ratings_given int not null,	
booking_status enum('Cancelled','Checked Out','No Show') not null,	
revenue_generated int not null,
revenue_realized int not null,
primary key (booking_id),
foreign key (property_id) references dim_hotels(property_id),
foreign key (check_in_date) references dim_date(date_d),
foreign key(room_category) references dim_rooms(room_id)
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_date.csv"
into table dim_date
fields terminated by ','
ignore 1 rows;

select * from dim_date;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_hotels.csv"
into table dim_hotels
fields terminated by ','
ignore 1 rows;

select * from dim_hotels;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_rooms.csv"
into table dim_rooms
fields terminated by ','
ignore 1 rows;

select * from dim_rooms;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_aggregated_bookings.csv"
into table fact_aggregated_bookings
fields terminated by ','
ignore 1 rows;

select * from fact_aggregated_bookings;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_bookings.csv"
into table fact_bookings
fields terminated by ','
ignore 1 rows;

select * from fact_bookings;

*/

