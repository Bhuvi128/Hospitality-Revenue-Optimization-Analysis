# Hospitality Revenue Optimization

![Hospitality](images/Hospitality.jpg)

## 📑Table of Contents

- [Project Overview](#project-overview)
- [Data Sources](#data-sources)
- [Tools](#tools)
- [Data Cleaning and Preparation](#data-cleaning-and-preparation)
- [Database & tables creation](#database--tables-creation)
- [SQL Queries](#sql-queries)
- [Exploratory Data Analysis (EDA)](#exploratory-data-analysis-eda)
- [Interactive dashboard](#interactive-dashboard)
- [Results/Findings](#resultsfindings)
- [Recommendations](#recommendations)

### 📁Project Overview 

This project is focused on helping a luxury hotel chain—AtliQ Grands—leverage its historical booking data to make smarter business decisions. 
The goal is to analyze patterns in bookings, room preferences, cancellations, and seasonal trends to uncover insights that can optimize revenue, reduce losses, and 
improve operational efficiency.

### 🌐Data Sources

- <b>fact_bookings:</b> This table represents detailed information about bookings, property id in which property the booking made, when they booked, check-in and check-out date, no. of guests per booking, room category, in which 
booking platform they booked, how many ratings were given per booking, bookings status whether the booking was checked out, Cancelled or No show, How much revenue generated and
How much revenue was realized after refunds for canceled bookings? <br>
- <b>fact_aggregated_bookings:</b> This table represents detailed information about property, check-in date, room category, successful bookings made on that particular check-in date,
How many rooms are available on that day? <br>
- <b>dim_rooms:</b> Contains information about room class for a particular room category.<br>
- <b>dim_hotels:</b> Contains information about Property name, category, and city for particular Property_id. <br>
- <b>dim_date:</b> Contains information about day type, week no., month and year in which month, year, and week no the check-in was done, whether the bookings are in weekdays or weekends. <br>

### 💻Tools

- Excel - Data Cleaning
- Sql - Creating database, tables, data retrieval, and data querying
- Python - Exploratory Data analysis
- Sqlalchemy - Loading SQL data into python
- Pymysql - Integrate MySQL server to sqlalchemy to load SQL data into python
- Pandas - Data manipulation
- Matplotlib & Seaborn - Data visualization
- Scipy - Statistical testing and analysis
- Tableau - Creating interactive dashboard and reports

### 🔍Data Cleaning and Preparation

To import tables to the MySQL server, I first cleaned and prepared the data using Excel by performing data type conversions and handling null values, ensuring the dataset was ready for seamless integration into the SQL tables.

<p>
  <a href="https://github.com/Bhuvi128/Hospitality-Revenue-Optimization-Analysis/tree/main/Data%20Cleaning%20using%20Excel" target="_blank" style="text-decoration:none;">
    <img src="https://img.shields.io/badge/View-Excel_Cleaning_Files-217346?style=for-the-badge&logo=microsoft-excel&logoColor=white" alt="Download Excel Data Cleaning File">
  </a>
</p>

### 💾Database & tables creation

After preparing and cleaning the data in Excel by handling null values and converting data types, I created the database and corresponding tables in MySQL. Then, I imported the cleaned data into these tables. The database schema is illustrated in the image below.<br>

![ER Diagram](images/ER_Diagram.png)

### 🧾SQL Queries

Executed SQL queries on the atliq_hospitality database to extract relevant data from multiple tables, joined them meaningfully, cleaned and filtered records based on booking status, performed initial aggregations like total revenue and guest distribution, and reduced the processing load in Python by preparing a structured dataset for efficient exploratory data analysis.<br>

1. Booking status distribution

```sql
select booking_status, count(*) as total_bookings
from fact_bookings
group by booking_status;
```

2. Room class distribution

```sql
select dr.room_class, count(*) as total_bookings
from dim_rooms dr right join fact_bookings fb
on dr.room_id = fb.room_category
group by dr.room_class;
```

3. Booking trends by month

```sql
select monthname(booking_date) booking_month, count(*) as total_bookings
from fact_bookings
group by booking_month
order by field(booking_month, 'April', 'May', 'June', 'July');
```

4. Platform-wise booking status

```sql
select booking_platform, booking_status,
count(*) as total_bookings
from fact_bookings
group by booking_platform, booking_status
order by total_bookings;
```

5. Stay duration trends by booking status

```sql
select datediff(checkout_date, check_in_date) as stay_duration, 
booking_status,
count(*) as total_bookings
from fact_bookings
group by stay_duration, booking_status
order by stay_duration, total_bookings;
```

6. Average revenue generated vs realized per booking status

```sql
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
```

7. Average revenue generated vs realized per property category

```sql
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
```

8. Daily successful bookings vs capacity per city

```sql
select fa.check_in_date, dh.city,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_hotels dh
on fa.property_id = dh.property_id
group by fa.check_in_date, dh.city
order by fa.check_in_date;
```

9. Daily successful bookings vs capacity per month with year

```sql
select fa.check_in_date, dd.mmm_yy,
sum(fa.successful_bookings) as total_successful_bookings,
sum(fa.capacity) as total_capacity,
round(100 * sum(successful_bookings) / sum(capacity),2) as utilization_percent
from fact_aggregated_bookings fa
left join dim_date dd
on fa.check_in_date = dd.date_d
group by fa.check_in_date, dd.mmm_yy
order by fa.check_in_date;
```

10. Are cancellations happening more on weekends or weekdays?

```sql
select dd.day_type, 
sum(case when fb.booking_status = 'Cancelled' then 1 else 0 end) cancelled_bookings,
sum(case when fb.booking_status != 'Cancelled' then 1 else 0 end) successfull_bookings,
round(100 * sum(case when booking_status = 'Cancelled' then 1 else 0 end) / count(*),2) as cancellation_rate_pct
from fact_bookings fb left join dim_date dd
on fb.check_in_date = dd.date_d
group by dd.day_type
order by cancelled_bookings desc;
```

<p>
  <a href="https://github.com/Bhuvi128/Hospitality-Revenue-Optimization-Analysis/blob/main/Hospitality%20Revenue%20Analysis.sql" target="_blank" style="text-decoration:none;">
    <img src="https://img.shields.io/badge/View-MySQL_Script-lightblue?style=for-the-badge&logo=mysql&logoColor=white" alt="MySQL Script">
  </a>
</p>

### ✨🔍Exploratory Data Analysis (EDA)

Performed in-depth exploratory analysis to understand booking behaviors, revenue trends, and cancellation patterns.EDA has been performed on various factors, such as:<br>

- <b>Distribution Analysis of:</b>
  - Revenue generated
  - Revenue (Generated vs. Realized) by cancelled bookings
  - Booking Status (Successful vs. Cancelled)
  - Property Name, City, Category, Room Class, Ratings, Number of Guests, Booking platform, booking month, and stay duration.
  - Successful bookings and cancelled bookings by day type.
  - Successful bookings and cancelled bookings by week no.
  - Successful bookings vs Capacity over time.

- <b>Revenue Relationship:</b>
  - Analyzed the correlation between generated and realized revenue.
  - Analyzed the correlation between generated and realized revenue with various factors like room class, property name, city, category, and booking status.

- <b>Hypothesis Testing:</b>
  - Test the percentage of revenue realized after cancellations using statistical methods.

- <b>Cancellation Patterns:</b>
  - Explored how Cancellations vary across Room Class, Property Name, Category, City, Ratings, Number of Guests, Booking month, Booking Platform, Stay Duration, and Day Type

- <b>Successful bookings vs Capacity Over time</b>
  - Compare successful bookings with capacity using Room Class, Property Name, City, Category, Month with Year, Week No, and Day Type.

<p>
  <a href="https://github.com/Bhuvi128/Hospitality-Revenue-Optimization-Analysis/blob/main/Hospitality%20Revenue%20Optimzation.ipynb" target="_blank" style="text-decoration:none;">
    <img src="https://img.shields.io/badge/View-Python_Notebook-orange?style=for-the-badge&logo=jupyter" alt="Python Notebook">
  </a>
</p>

### 📊Interactive dashboard

Designed and developed an interactive Tableau dashboard to enable stakeholders to monitor hotel performance trends and metrics over time.

![Dashboard](Hospitality-Dashboard.png)<br>

<p>
  <a href="https://public.tableau.com/app/profile/bhuvanendiran.s/viz/HospitalityRevenueAnalysisDashboard/HospitalityDashboard" target="_blank" style="text-decoration:none;">
    <img src="https://img.shields.io/badge/View-Dashboard-blue?style=for-the-badge&logo=tableau" alt="View Dashboard">
  </a>
  
  <a href="https://github.com/Bhuvi128/Hospitality-Revenue-Optimization-Analysis/tree/main/Tableau%20dashobard" target="_blank" style="text-decoration:none;">
    <img src="https://img.shields.io/badge/Download-Dashboard-brightgreen?style=for-the-badge&logo=github" alt="Download Dashboard">
  </a>
</p>

### 📝Results/Findings

- <b>Booking Behavior</b>
  - The majority of bookings are successfully checked out.
  - Cancellations are frequent; no-shows are minimal.
  - Indicates proactive cancellation behavior by guests.

- <b>Revenue Insights</b>
  - Revenue Generated is skewed with a few high-value bookings.
  - Revenue Realized varies widely due to cancellations and refunds.
  - There is a clear positive correlation between generated and realized revenue.

- <b>Impact of Cancellations</b>
  - Cancelled bookings yield minimal revenue.
  - High-value bookings are more prone to financial loss on cancellation.
  - Suggests need for refined refund policies for premium bookings.

- <b>Refund Consistency</b>
  - Statistical tests confirm a uniform refund pattern (~60% refunded).
  - Indicates a stable and predictable cancellation policy.

- <b>Room Class & Property Performance</b>
  - Elite and Standard rooms are most preferred.
  - Presidential rooms show a high variance in revenue.
  - Luxury properties outperform Business ones in booking volume.
  - Atliq Palace, Atliq Exotica, and Atliq City are top-performing properties.
  - Atliq Seasons is underperforming, indicating potential areas for improvement.

- <b>City-Wise Trends</b>
  - Mumbai dominates in bookings, followed by Hyderabad and Bangalore.
  - Delhi underperforms, pointing to potential strategic gaps.

- <b>Bookings by Day Type (Weekday vs Weekend)</b>
  - Weekdays see higher booking activity — both successful and cancelled.
  - Weekend bookings are fewer but more committed, with lower cancellation rates.
  - Suggests tentative bookings happen on weekdays and leisure/stable bookings on weekends.

- <b>Bookings by Week Number</b>
  - Bookings stay fairly consistent across weeks, except for a dip in Week 32 — could be due to seasonality or data issues.
  - Weeks 27–29 show higher cancellations, possibly due to external factors (e.g., weather, pricing).
 
- <b>Bookings vs Capacity Over Time</b>
  - Capacity is stable, but bookings are consistently below full occupancy.
  - Clear weekly cycles indicate predictable customer behavior.

### 📝🚀Recommendations

To regain its lost market share and revenue in the luxury and business hotel segment, AtliQ Grands should adopt a data-driven, customer-centric strategy that emphasizes flexible pricing, targeted marketing, and operational agility.<br>
The analysis reveals patterns in customer behavior (e.g., weekday bookings with high cancellations, underutilized room types, and regional disparities in performance) that highlight the need for tailored interventions across booking periods, room categories, and locations.<br>

Key areas of focus should include:

- <b>Dynamic Pricing & Promotions:</b> Use demand forecasting to align pricing and offers with booking trends and seasonal patterns.
- <b>Product Repositioning:</b> Rebrand or bundle underperforming room types and properties to better meet customer expectations.
- <b>City-Specific Strategies:</b> Allocate resources based on city-level performance, doubling down on high-performing regions and investigating issues in weaker markets.
- <b>Customer Retention & Personalization:</b> Introduce loyalty programs and personalized marketing to build long-term customer relationships and reduce cancellations.
- <b>Operational Efficiency:</b> Align staffing and capacity with demand to improve profitability during low-traffic periods.
- <b>Refund Policies:</b> Implement Stricter Cancellation policies and reduce the refund percentage to avoid higher revenue loss for cancelled bookings.

By integrating these insights into strategic decision-making, AtliQ Grands can position itself as a forward-thinking, resilient brand in India’s competitive hospitality industry, leading to improved occupancy, revenue, and customer satisfaction.
