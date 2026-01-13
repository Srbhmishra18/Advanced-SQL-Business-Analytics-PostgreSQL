# Advanced SQL Business Analytics (PostgreSQL)

## Project Overview

This project demonstrates an end-to-end SQL-based analytics workflow built on a real-world e-commerce dataset.  The objective was to design an analytics-ready relational data model, perform data quality validation, and answer key business and operational questions using advanced SQL techniques.

The project focuses on customer behavior, revenue concentration, and delivery performance, reflecting typical analytical problems faced by data teams in production environments.

---

## Dataset

The analysis is based on the **Olist Brazilian E-Commerce Dataset**, which contains transactional data across orders, customers, products, sellers, payments, reviews, and logistics. 

**Key characteristics of the dataset:**

- Multiple related entities (orders, customers, items, products, sellers)
- Time-based purchase and delivery data
- Realistic data quality challenges (duplicates, missing values, delayed deliveries)

This makes the dataset suitable for relational modeling, cohort analysis, and operational analytics.

---

## Data Model & Architecture

The project follows a **two-layer architecture**:

### 1. Raw Layer (`raw` schema)

- Direct ingestion of CSV files into PostgreSQL
- Tables closely mirror the source data structure
- Used only as a staging layer (no analytics performed here)

### 2. Analytics Layer (`analytics` schema)

- Star-schema-style analytical model
- Clear separation between dimensions and fact tables

**Key tables:**

- **Dimensions:** `dim_date`, `dim_customer`, `dim_product`, `dim_seller`, `dim_geography`
- **Facts:** `fact_orders`, `fact_order_items`

This structure enables: 

- ✅ Efficient joins
- ✅ Reusable KPI views
- ✅ Clear business logic separation

---

## Data Quality & Validation

Before performing the analysis, several data quality checks were executed to ensure reliability:

- ✔️ Primary key uniqueness checks on fact and dimension tables
- ✔️ Foreign key integrity validation between facts and dimensions
- ✔️ Business sanity checks (e.g., delivered orders without delivery dates, negative delivery durations)

These checks help prevent misleading KPIs and incorrect conclusions, a critical requirement in real business environments. 

---

## Key KPIs Defined

The following KPIs were implemented using SQL views:

- **Total orders**
- **Total revenue** (item price + freight)
- **Average order value (AOV)**
- **Unique customers per day**
- **Delivery delay rate**
- **Average delivery time**
- **Average delivery delay** (for delayed orders)

All KPIs are calculated directly in PostgreSQL and can be reused by downstream tools (e.g., BI dashboards).

---

## Advanced SQL Analyses

### 1. Cohort Retention Analysis

Customers were grouped into cohorts based on their first purchase month, and retention was tracked for up to 12 months after the initial purchase.

**Key observations:**

- Retention drops sharply after the first purchase month
- Average retention declines from 100% at month 0 to approximately **5%** at month 1 and **0.25%** by month 3
- Long-term retention beyond 6 months remains low, indicating limited repeat purchasing behavior

This analysis highlights challenges in customer loyalty and long-term engagement.

### 2. Revenue Concentration (Pareto Analysis)

Revenue was analyzed at the product category level using window functions to compute cumulative contribution.

**Key observations:**

- Revenue is highly concentrated
- The top **17** product categories account for approximately **80%** of total revenue
- This confirms a strong Pareto (80/20) effect, suggesting that business performance is driven by a small subset of categories

This insight can support pricing, inventory, and marketing prioritization decisions.

### 3. Delivery Performance & Delay Drivers

Delivery performance was analyzed across customer locations and product characteristics. 

**Key observations:**

- The overall delivery delay rate is approximately **8.1%**
- Certain states exhibit significantly higher delay rates, with the worst-performing states exceeding a **23%** delay rate
- Delayed orders take on average **13** additional days compared to on-time deliveries
- Larger and heavier products show a higher likelihood of late delivery compared to smaller items

These findings highlight operational bottlenecks and potential areas for logistics optimization.

---

## Tools & Technologies

| Tool | Purpose |
|------|---------|
| **PostgreSQL** | Database management system |
| **SQL** | CTEs, window functions, analytical queries |
| **DBeaver** | Development environment |
| **Git & GitHub** | Version control |

---

## Key Takeaways

✅ Designed an analytics-ready relational data model from raw transactional data  
✅ Applied advanced SQL techniques (CTEs, window functions, cohort logic)  
✅ Translated raw data into business-relevant insights  
✅ Demonstrated analytical thinking aligned with real-world data team workflows  

---

## About This Project

This project was created as part of my journey to master SQL for business analytics and data engineering. It showcases my ability to work with real-world datasets, design scalable data models, and derive actionable insights using SQL.
