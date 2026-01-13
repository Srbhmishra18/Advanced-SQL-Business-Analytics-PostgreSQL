-- Calculate revenue per order
WITH order_revenue AS (
  SELECT
    oi.order_id,
    SUM(oi.price + oi.freight_value) AS revenue
  FROM analytics.fact_order_items oi
  GROUP BY oi.order_id
),
-- Building customer-level metrics (R, F, M inputs)
customer_metrics AS (
  SELECT
    o.customer_id,
    MAX(d.date) AS last_purchase_date,
    COUNT(DISTINCT o.order_id) AS frequency,
    SUM(r.revenue) AS monetary
  FROM analytics.fact_orders o
  JOIN analytics.dim_date d ON d.date_id = o.order_purchase_date_id
  LEFT JOIN order_revenue r ON r.order_id = o.order_id
  WHERE o.status IN ('delivered','shipped','invoiced','processing','approved')
  GROUP BY o.customer_id
),
-- Assign RFM scores using NTILE(5)
scored AS (
  SELECT
    customer_id,
    -- Recency in days (lower = better)
    (CURRENT_DATE - last_purchase_date) AS recency_days,
    frequency,
    monetary,
    -- Recency score: higher score = more recent
    NTILE(5) OVER (ORDER BY (CURRENT_DATE - last_purchase_date) DESC) AS r_score,
    -- Frequency score: higher score = more purchases
    NTILE(5) OVER (ORDER BY frequency) AS f_score,
    -- Monetary score: higher score = more spending
    NTILE(5) OVER (ORDER BY monetary) AS m_score
  FROM customer_metrics
)
-- Final RFM output with segmentation labels
SELECT
  customer_id,
  recency_days,
  frequency,
  monetary,
  r_score, f_score, m_score,
  (r_score::text || f_score::text || m_score::text) AS rfm_score,
  CASE
    WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
    WHEN r_score >= 4 AND f_score >= 3 THEN 'Loyal'
    WHEN r_score >= 3 AND f_score >= 2 THEN 'Potential'
    WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
    ELSE 'Lost'
  END AS segment
FROM scored;
