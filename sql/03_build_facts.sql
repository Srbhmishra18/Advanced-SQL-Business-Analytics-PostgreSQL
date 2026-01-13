--  ********************Building fact tables********************


-- Creating fact table fact_orders
drop table if exists analytics.fact_orders cascade;

--creating the table
create table analytics.fact_orders as 
select
o.order_id,
o.customer_id,
(extract(year from o.order_purchase_timestamp::date)::int *10000 +
extract(month from o.order_purchase_timestamp::date)::int * 100 +
extract(day from o.order_purchase_timestamp::date)::int) as order_purchase_date_id,
case when o.order_delivered_customer_date = '' then null
else (extract(year from o.order_delivered_customer_date::date)::int * 10000 +
extract(month from o.order_delivered_customer_date::date)::int * 100 +
extract(day from o.order_delivered_customer_date::date)::int) end as order_delivered_date_id,
(extract(year from o.order_estimated_delivery_date::date)::int * 10000 + 
extract(month from o.order_estimated_delivery_date::date)::int * 100 +
extract(day from o.order_estimated_delivery_date::date)::int) as order_estimated_delivery_date_id,
o.order_status as status,
case when o.order_delivered_customer_date = '' then null
else
(o.order_delivered_customer_date::date - o.order_purchase_timestamp::date) end as delivery_days,
case when o.order_delivered_customer_date = '' then null
else
(o.order_delivered_customer_date::date - o.order_estimated_delivery_date::date) end as delivery_delay_days,
case when o.order_delivered_customer_date = '' then null
else
(o.order_delivered_customer_date> o.order_estimated_delivery_date) end as is_delayed
from raw.orders o;

-- setting the primary key
ALTER TABLE analytics.fact_orders
  ADD CONSTRAINT pk_fact_orders PRIMARY KEY (order_id);
 
-- setting the foreign key
ALTER TABLE analytics.fact_orders
  ADD CONSTRAINT fk_fact_orders_customer
  FOREIGN KEY (customer_id) REFERENCES analytics.dim_customer(customer_id);
  
--*****************************************************************************************************************************************
 
-- creating fact table fact_order_items
drop table if exists analytics.fact_order_items cascade;

-- creating the table 
create table analytics.fact_order_items as 
select
	oi.order_id,
	oi.order_item_id::int as order_item_id,
	oi.product_id,
	oi.seller_id,
	(extract(year from oi.shipping_limit_date::date)::int * 10000+
	extract(month from oi.shipping_limit_date::date)::int * 100 +
	extract(day from oi.shipping_limit_date::date)::int) as shipping_limit_date_id,
	oi.price::numeric as price,
	oi.freight_value::numeric as freight_value
from raw.order_items oi;

-- setting the primary key
alter table analytics.fact_order_items add constraint pk_fact_order_items primary key (order_id,order_item_id);

-- setting the foreign keys
alter table analytics.fact_order_items add constraint fk_foi_order foreign key (order_id) references analytics.fact_orders(order_id);
alter table analytics.fact_order_items add constraint fk_foi_product foreign key (product_id) references analytics.dim_product(product_id);
alter table analytics.fact_order_items add constraint fk_foi_seller foreign key (seller_id) references analytics.dim_seller(seller_id); 

--*****************************************************************************************************************************************

-- adding performance indexes
CREATE INDEX IF NOT EXISTS idx_fact_orders_customer ON analytics.fact_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_fact_orders_purchase_date ON analytics.fact_orders(order_purchase_date_id);
CREATE INDEX IF NOT EXISTS idx_fact_items_product ON analytics.fact_order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_fact_items_seller ON analytics.fact_order_items(seller_id);
