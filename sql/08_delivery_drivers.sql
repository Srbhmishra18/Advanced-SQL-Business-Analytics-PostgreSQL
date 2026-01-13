--Delivery Delay Drivers
SELECT
  c.state,
  COUNT(*) AS delivered_orders,
  AVG(CASE WHEN o.is_delayed THEN 1 ELSE 0 END)::numeric(5,3) AS delay_rate,
  AVG(o.delivery_delay_days)::numeric(10,2) AS avg_delay_days
FROM analytics.fact_orders o
JOIN analytics.dim_customer c
  ON c.customer_id = o.customer_id
WHERE o.is_delayed IS NOT NULL
GROUP BY c.state
ORDER BY delay_rate DESC;


-- **********************************************************************************

-- delay by product size band
SELECT
  CASE
    WHEN p.weight_g < 500 THEN 'Small'
    WHEN p.weight_g < 2000 THEN 'Medium'
    ELSE 'Large'
  END AS size_band,
  COUNT(*) AS orders,
  AVG(CASE WHEN o.is_delayed THEN 1 ELSE 0 END)::numeric(5,3) AS delay_rate
FROM analytics.fact_order_items oi
JOIN analytics.fact_orders o ON o.order_id = oi.order_id
JOIN analytics.dim_product p ON p.product_id = oi.product_id
WHERE o.is_delayed IS NOT NULL
GROUP BY size_band
ORDER BY size_band;