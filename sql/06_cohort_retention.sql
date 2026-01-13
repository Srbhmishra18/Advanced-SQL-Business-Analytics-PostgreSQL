
-- ********** Cohort retention view ******************
create or replace view analytics.vw_cohort_retention as(
	-- Extract all customer orders with purchase dates
	WITH customer_orders AS (
	  SELECT
	    c.customer_unique_id,
	    d.date AS purchase_date,
	    -- Normalize purchase date to month level
	    date_trunc('month', d.date)::date AS purchase_month
	  FROM analytics.fact_orders o
	  JOIN analytics.dim_customer c
	    ON c.customer_id = o.customer_id
	  JOIN analytics.dim_date d
	    ON d.date_id = o.order_purchase_date_id
	  WHERE o.status IN ('delivered','shipped','invoiced','processing','approved')
	),
	-- Determine each customer's first purchase month (their cohort)
	first_month AS (
	  SELECT
	    customer_unique_id,
	    MIN(purchase_month) AS cohort_month
	  FROM customer_orders
	  GROUP BY customer_unique_id
	),
	-- Compute activity per cohort per month
	cohort_activity AS (
	  SELECT
	    f.cohort_month,
	    c.purchase_month,
	    ((DATE_PART('year', c.purchase_month) - DATE_PART('year', f.cohort_month)) * 12
	     + (DATE_PART('month', c.purchase_month) - DATE_PART('month', f.cohort_month)))::int AS month_index,
	     -- Count distinct active customers in that cohort-month
	    COUNT(DISTINCT c.customer_unique_id) AS active_customers
	  FROM customer_orders c
	  JOIN first_month f
	    ON f.customer_unique_id = c.customer_unique_id
	  GROUP BY 1,2,3
	),
	-- Determine cohort size (month_index = 0)
	cohort_size AS (
	  SELECT
	    cohort_month,
	    MAX(active_customers) FILTER (WHERE month_index = 0) AS cohort_customers
	  FROM cohort_activity
	  GROUP BY cohort_month
	)
	-- Final output with retention rate
	SELECT
	  a.cohort_month,
	  a.month_index,
	  a.active_customers,
	  s.cohort_customers,
	  ROUND(a.active_customers::numeric / NULLIF(s.cohort_customers,0), 4) AS retention_rate
	FROM cohort_activity a
	JOIN cohort_size s USING (cohort_month)
	WHERE a.month_index BETWEEN 0 AND 12
	ORDER BY a.cohort_month, a.month_index
);

-- View check
select * from analytics.vw_cohort_retention;
  

-- Retention decay analysis
SELECT
  month_index,
  ROUND(AVG(retention_rate), 4) AS avg_retention
FROM analytics.vw_cohort_retention
WHERE month_index BETWEEN 0 AND 6
GROUP BY month_index
ORDER BY month_index;
