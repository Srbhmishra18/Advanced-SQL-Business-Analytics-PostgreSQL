--  ********************Building dimension tables********************


-- Creating dimension table dim_date for date related analytics
--drop any table if exist and create a new one
DROP TABLE IF EXISTS analytics.dim_date CASCADE;

-- creating the schema
CREATE TABLE analytics.dim_date (
  date_id INT PRIMARY KEY,
  date DATE NOT NULL,
  year INT NOT NULL,
  quarter INT NOT NULL,
  month INT NOT NULL,
  week INT NOT NULL,
  day_of_week INT NOT NULL,
  is_weekend BOOLEAN NOT NULL
);

-- the upper and lower bounds are the min and max date from the orders table 
WITH bounds AS (
  SELECT
    MIN(order_purchase_timestamp::date) AS min_d,
    MAX(order_estimated_delivery_date::date) AS max_d
  FROM raw.orders
)
INSERT INTO analytics.dim_date
SELECT
  (EXTRACT(YEAR FROM d)::int * 10000 + EXTRACT(MONTH FROM d)::int * 100 + EXTRACT(DAY FROM d)::int) AS date_id,
  d::date AS date,
  EXTRACT(YEAR FROM d)::int AS year,
  EXTRACT(QUARTER FROM d)::int AS quarter,
  EXTRACT(MONTH FROM d)::int AS month,
  EXTRACT(WEEK FROM d)::int AS week,
  EXTRACT(ISODOW FROM d)::int AS day_of_week,
  (EXTRACT(ISODOW FROM d)::int IN (6,7)) AS is_weekend
FROM bounds, generate_series(bounds.min_d, bounds.max_d, interval '1 day') d;

--*****************************************************************************************

-- Creating dimension table dim_customer
--drop any table if exist and create a new one
DROP TABLE IF EXISTS analytics.dim_customer CASCADE;

-- creating the table
CREATE TABLE analytics.dim_customer AS
SELECT
  customer_id,
  customer_unique_id,
  customer_zip_code_prefix AS zip_prefix,
  customer_city AS city,
  customer_state AS state
FROM raw.customers;

-- setting the primary key
ALTER TABLE analytics.dim_customer
  ADD CONSTRAINT pk_dim_customer PRIMARY KEY (customer_id);

--*****************************************************************************************
 
 -- Creating dimension table dim_seller
 -- drop table if already exist
 drop table if exists analytics.dim_seller cascade;
 
--creating the table 
create table analytics.dim_seller as
select
	seller_id,
	seller_zip_code_prefix AS zip_prefix,
	seller_city as city,
	seller_state as state
from raw.sellers;

-- setting the primary key
ALTER TABLE analytics.dim_seller
  ADD CONSTRAINT pk_dim_seller PRIMARY KEY (seller_id);

--*****************************************************************************************
 
-- Creating dimension table dim_product
-- drop table if already exist
drop table if exists analytics.dim_product cascade;

--creating the table
create table analytics.dim_product as 
select
product_id,
coalesce (t.product_category_name_english,p.product_category_name) as category,
product_photos_qty as photos_showcased,
product_weight_g::numeric as weight_g,
product_length_cm::numeric as length_cm,
product_height_cm::numeric as height_cm,
product_width_cm::numeric as width_cm
from raw.products p 
left join raw.category_translation t on
p.product_category_name = t.product_category_name;

-- setting the primary key
alter table analytics.dim_product add constraint pk_dim_product primary key (product_id);

--*****************************************************************************************

-- Creating dimension table dim_geolocation
-- drop table if already exist
drop table if exists analytics.dim_geography cascade;

--creating the table
create table analytics.dim_geography as 
select
geolocation_zip_code_prefix as zip_code,
avg(geolocation_lat::numeric) as latitude,
avg(geolocation_lng::numeric) as longitude,
max(geolocation_city) as city,
max(geolocation_state) as state
from raw.geolocation group by geolocation_zip_code_prefix;

-- setting the primary key
alter table analytics.dim_geography add constraint pk_dim_geography primary key (zip_code);
