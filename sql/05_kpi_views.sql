
-- daily revenue and average order value view
create or replace view analytics.vw_daily_kpis as
with order_revenue as (
select
oi.order_id,
sum(oi.price+oi.freight_value) as revenue  -- revenue is sum of total price and freight value
from analytics.fact_order_items oi
group by oi.order_id 
)
select 
d."date"  ,
count(distinct o.order_id) as orders,
count(distinct o.customer_id) as unique_customers,
coalesce (sum(r.revenue),0) as revenue,    -- using coalesce if the revenue is null
round(
case when count(distinct o.order_id) = 0 then 0
else coalesce(sum(r.revenue),0)/count(distinct o.order_id)::numeric(10,3)
end,
3) as avg_order_value       -- rounding the value to 3 decimal places
from analytics.fact_orders o
join analytics.dim_date d 
on d.date_id  = o.order_purchase_date_id 
left join order_revenue r 
on r.order_id = o.order_id 
group by d."date";

-- testing the view
select * from analytics.vw_daily_kpis order by date limit 50;

-- Calculating delayed rate
select avg(case when is_delayed then 1 else 0 end)::numeric(5,3) as delayed_rate from analytics.fact_orders where is_delayed is not null;


-- daily revenue and average order value view
CREATE OR REPLACE VIEW analytics.vw_delivery_kpis AS
SELECT
  d.date,
  COUNT(*) FILTER (WHERE o.is_delayed IS NOT NULL) AS delivered_orders,
  AVG(o.delivery_days)::numeric(10,2) AS avg_delivery_days,
  AVG(CASE WHEN o.is_delayed THEN 1 ELSE 0 END)::numeric(10,4) AS delayed_rate,
  AVG(CASE WHEN o.is_delayed THEN o.delivery_delay_days ELSE NULL END)::numeric(10,2) AS avg_delay_days
FROM analytics.fact_orders o
JOIN analytics.dim_date d
  ON d.date_id = o.order_purchase_date_id
GROUP BY d.date;


-- testing the view
select * from analytics.vw_delivery_kpis order by delivered_orders desc limit 10;