-- Duplicate order_id
SELECT order_id, COUNT(*)
FROM analytics.fact_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

-- Duplicate customer_id in dim_customer (should be 0)
SELECT customer_id, COUNT(*)
FROM analytics.dim_customer
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Duplicate order-item PK
SELECT order_id, order_item_id, COUNT(*)
FROM analytics.fact_order_items
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;

-- Items without orders
SELECT oi.*
FROM analytics.fact_order_items oi
LEFT JOIN analytics.fact_orders o ON o.order_id = oi.order_id
WHERE o.order_id IS NULL
LIMIT 50;

-- Orders without customers
SELECT o.*
FROM analytics.fact_orders o
LEFT JOIN analytics.dim_customer c ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL
LIMIT 50;

-- Delivered status but missing delivered date_id
SELECT *
FROM analytics.fact_orders
WHERE status = 'delivered' AND order_delivered_date_id IS NULL
LIMIT 50;

-- Negative delivery days
SELECT *
FROM analytics.fact_orders
WHERE delivery_days < 0
LIMIT 50;
