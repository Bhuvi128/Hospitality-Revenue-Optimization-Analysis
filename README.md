# Hospitality Revenue Optimization

### Project Overview

This project is focused on helping a luxury hotel chain—AtliQ Grands—leverage its historical booking data to make smarter business decisions. 
The goal is to analyze patterns in bookings, room preferences, cancellations, and seasonal trends to uncover insights that can optimize revenue, reduce losses, and 
improve operational efficiency.

### Data Sources

<b>fact_bookings:</b> This table represents detailed information about bookings, property id in which property the booking made, when they booked, check-in and check-out date, no. of guests per booking, room category, in which 
booking platform they booked, how many ratings were given per booking, bookings status whether the booking was checked out, Cancelled or No show, How much revenue generated and
How much revenue was realized after refunds for canceled bookings? <br>
<b>fact_aggregated_bookings:</b> This table represents detailed information about property, check-in date, room category, successful bookings made on that particular check-in date,
How many rooms are available on that day? <br>
<b>dim_rooms:</b> Contains information about room class for a particular room category.<br>
<b>dim_hotels:</b> Contains information about Property name, category, and city for particular Property_id. <br>
<b>dim_date:</b> Contains information about day type, week no., month and year in which month, year, and week no the check-in was done, whether the bookings are in weekdays or weekends. <br>

### Tools

- Excel - Data Cleaning
- Sql - Creating database, tables, data retrieval, and data querying
- Python - Exploratory Data analysis
- Sqlalchemy - Loading SQL data into python
- Pandas - Data manipulation
- Matplotlib & Seaborn - Data visualization
- Scipy - Statistical testing and analysis
- Tableau - Creating interactive dashboard and reports

### Data Cleaning and Preparation

To import tables to the MySQL server, I first cleaned and prepared the data using Excel by performing data type conversions and handling null values, ensuring the dataset was ready for seamless integration into the SQL tables.

### Database & tables creation

After preparing and cleaning the data in Excel by handling null values and converting data types, I created the database and corresponding tables in MySQL. Then, I imported the cleaned data into these tables.

### Exploratory Data Analysis (EDA)

Performed in-depth exploratory analysis to understand booking behaviors, revenue trends, and cancellation patterns.EDA has been performed on various factors, such as:<br>

<b>Distribution Analysis of:</b>
- Revenue (Generated vs. Realized)
- Revenue (Generated vs. Realized) by cancelled bookings
- Booking Status (Successful vs. Canceled)
- Property Name, City, Category, Room Class, Ratings, Number of Guests, Booking platform, booking month, and stay duration.
- Successful bookings vs Capacity by day type.
- Successful bookings vs Capacity by week no.
- Successful bookings vs Capacity over time.

<b>Revenue Relationship:</b>
- Analyzed the correlation between generated and realized revenue.
- Analyzed the correlation between generated and realized revenue with various factors like room class, property name, city, category, and booking status.

<b>Hypothesis Testing:</b>
- Test the percentage of revenue realized after cancellations using statistical methods.

<b>Cancellation Patterns:</b>
- Explored how Cancellations vary across Room Class, Property Name, Category, City, Ratings, Number of Guests, Booking month, Booking Platform, Stay Duration, and Day Type

<b>Successful bookings vs Capacity Over time</b>
- Compare successful bookings with capacity using Room Class, Property Name, City, Category, Month with Year, Week No, and Day Type.


