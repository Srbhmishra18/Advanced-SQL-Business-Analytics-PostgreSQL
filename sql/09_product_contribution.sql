-- Calculate total revenue per product category
WITH category_revenue AS (
  SELECT
    p.category,
    SUM(oi.price + oi.freight_value) AS revenue
  FROM analytics.fact_order_items oi
  JOIN analytics.dim_product p
    ON p.product_id = oi.product_id
  GROUP BY p.category
),
-- Add total revenue and cumulative revenue using window functions
ranked AS (
  SELECT
    category,
    revenue,
    SUM(revenue) OVER () AS total_revenue,
    SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue
  FROM category_revenue
)
-- Compute revenue share, cumulative share, and classify into Pareto groups
SELECT
  category,
  revenue,
  ROUND(revenue / total_revenue, 4) AS revenue_share,
  ROUND(cumulative_revenue / total_revenue, 4) AS cumulative_share,
  -- Classify categories into top 80% vs. remaining
  CASE
    WHEN cumulative_revenue / total_revenue <= 0.8 THEN 'Top 80%'
    ELSE 'Remaining'
  END AS pareto_group
FROM ranked
ORDER BY revenue DESC;
