/*
============================================================
Sales Performance & Business Intelligence Dashboard
Database: PostgreSQL
Purpose: KPI Reporting, Sales Analysis, Customer Insights,
Regional Performance Analysis and Executive MIS Reporting
============================================================
*/


-- ─────────────────────────────────────────────
-- TABLE SETUP (PostgreSQL)
-- ─────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS superstore (
    row_id          INT,
    order_id        VARCHAR(20),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(30),
    customer_id     VARCHAR(20),
    customer_name   VARCHAR(100),
    segment         VARCHAR(20),
    country         VARCHAR(50),
    city            VARCHAR(50),
    state           VARCHAR(50),
    postal_code     VARCHAR(10),
    region          VARCHAR(20),
    product_id      VARCHAR(20),
    category        VARCHAR(30),
    sub_category    VARCHAR(30),
    product_name    VARCHAR(200),
    sales           NUMERIC(10,4),
    quantity        INT,
    discount        NUMERIC(5,4),
    profit          NUMERIC(10,4)
);


-- ─────────────────────────────────────────────
-- 1. OVERALL KPI SUMMARY
-- ─────────────────────────────────────────────

SELECT
    ROUND(SUM(sales)::NUMERIC, 2)                           AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                          AS total_profit,
    COUNT(DISTINCT order_id)                                 AS total_orders,
    COUNT(DISTINCT customer_id)                              AS total_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)         AS avg_order_value,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)  AS profit_margin_pct
FROM superstore;


-- ─────────────────────────────────────────────
-- 2. MONTHLY REVENUE & PROFIT TREND
-- ─────────────────────────────────────────────

SELECT
    TO_CHAR(order_date, 'YYYY-MM')        AS year_month,
    ROUND(SUM(sales)::NUMERIC, 2)         AS monthly_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)        AS monthly_profit,
    COUNT(DISTINCT order_id)              AS total_orders,
    ROUND(SUM(quantity)::NUMERIC, 0)      AS units_sold,
    ROUND((SUM(profit) / NULLIF(SUM(sales),0)) * 100, 2) AS margin_pct
FROM superstore
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY year_month;


-- ─────────────────────────────────────────────
-- 3. REGIONAL PERFORMANCE BREAKDOWN
-- ─────────────────────────────────────────────

SELECT
    region,
    ROUND(SUM(sales)::NUMERIC, 2)                           AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                          AS total_profit,
    COUNT(DISTINCT order_id)                                 AS total_orders,
    COUNT(DISTINCT customer_id)                              AS unique_customers,
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2)         AS avg_order_value,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)  AS profit_margin_pct
FROM superstore
GROUP BY region
ORDER BY total_revenue DESC;


-- ─────────────────────────────────────────────
-- 4. PRODUCT CATEGORY & SUB-CATEGORY BREAKDOWN
-- ─────────────────────────────────────────────

SELECT
    category,
    sub_category,
    ROUND(SUM(sales)::NUMERIC, 2)                           AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                          AS total_profit,
    SUM(quantity)                                            AS units_sold,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)  AS profit_margin_pct
FROM superstore
GROUP BY category, sub_category
ORDER BY category, total_revenue DESC;


-- ─────────────────────────────────────────────
-- 5. YEARLY TARGETS vs ACTUALS
-- (Target = 15% growth over previous year)
-- ─────────────────────────────────────────────

WITH yearly_actuals AS (
    SELECT
        EXTRACT(YEAR FROM order_date)::INT  AS year,
        ROUND(SUM(sales)::NUMERIC, 2)       AS actual_revenue,
        ROUND(SUM(profit)::NUMERIC, 2)      AS actual_profit
    FROM superstore
    GROUP BY EXTRACT(YEAR FROM order_date)
),
with_targets AS (
    SELECT
        year,
        actual_revenue,
        actual_profit,
        ROUND(LAG(actual_revenue) OVER (ORDER BY year) * 1.15, 2) AS target_revenue,
        ROUND(LAG(actual_profit)  OVER (ORDER BY year) * 1.15, 2) AS target_profit
    FROM yearly_actuals
)
SELECT
    year,
    actual_revenue,
    COALESCE(target_revenue, ROUND(actual_revenue * 0.90, 2)) AS target_revenue,
    actual_profit,
    COALESCE(target_profit,  ROUND(actual_profit  * 0.90, 2)) AS target_profit,
    ROUND((actual_revenue / NULLIF(COALESCE(target_revenue, actual_revenue * 0.90), 0)) * 100, 2) AS rev_achievement_pct,
    ROUND((actual_profit  / NULLIF(COALESCE(target_profit,  actual_profit  * 0.90), 0)) * 100, 2) AS pft_achievement_pct
FROM with_targets
ORDER BY year;


-- ─────────────────────────────────────────────
-- 6. REVENUE VARIANCE: MONTH-OVER-MONTH
-- ─────────────────────────────────────────────

WITH monthly_rev AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM') AS year_month,
        ROUND(SUM(sales)::NUMERIC, 2)  AS revenue
    FROM superstore
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    year_month,
    revenue,
    LAG(revenue) OVER (ORDER BY year_month)                              AS prev_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY year_month), 2)         AS mom_variance,
    ROUND(
        ((revenue - LAG(revenue) OVER (ORDER BY year_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY year_month), 0)) * 100, 2
    )                                                                     AS mom_growth_pct
FROM monthly_rev
ORDER BY year_month;


-- ─────────────────────────────────────────────
-- 7. TOP 10 CUSTOMERS BY REVENUE
-- ─────────────────────────────────────────────

SELECT
    customer_name,
    segment,
    region,
    ROUND(SUM(sales)::NUMERIC, 2)                           AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                          AS total_profit,
    COUNT(DISTINCT order_id)                                 AS total_orders,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)  AS margin_pct
FROM superstore
GROUP BY customer_name, segment, region
ORDER BY total_revenue DESC
LIMIT 10;


-- ─────────────────────────────────────────────
-- 8. STATE-LEVEL DRILL-DOWN
-- ─────────────────────────────────────────────

SELECT
    state,
    region,
    ROUND(SUM(sales)::NUMERIC, 2)                           AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                          AS total_profit,
    COUNT(DISTINCT order_id)                                 AS total_orders,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)  AS profit_margin_pct
FROM superstore
GROUP BY state, region
ORDER BY total_revenue DESC
LIMIT 20;


-- ─────────────────────────────────────────────
-- 9. DISCOUNT IMPACT ON PROFIT
-- ─────────────────────────────────────────────

SELECT
    CASE
        WHEN discount = 0           THEN '0% (No Discount)'
        WHEN discount <= 0.10       THEN '1–10%'
        WHEN discount <= 0.20       THEN '11–20%'
        WHEN discount <= 0.30       THEN '21–30%'
        ELSE '30%+'
    END                                                      AS discount_band,
    COUNT(*)                                                 AS num_orders,
    ROUND(SUM(sales)::NUMERIC, 2)                           AS total_revenue,
    ROUND(SUM(profit)::NUMERIC, 2)                          AS total_profit,
    ROUND(AVG(profit)::NUMERIC, 2)                          AS avg_profit_per_order,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2)  AS profit_margin_pct
FROM superstore
GROUP BY discount_band
ORDER BY discount_band;


-- ─────────────────────────────────────────────
-- 10. SHIP MODE EFFICIENCY
-- ─────────────────────────────────────────────

SELECT
    ship_mode,
    COUNT(DISTINCT order_id)                                AS total_orders,
    ROUND(SUM(sales)::NUMERIC, 2)                          AS total_revenue,
    ROUND(AVG(ship_date - order_date), 1)                  AS avg_days_to_ship,
    ROUND((SUM(profit) / NULLIF(SUM(sales), 0)) * 100, 2) AS profit_margin_pct
FROM superstore
GROUP BY ship_mode
ORDER BY avg_days_to_ship;



-- ─────────────────────────────────────────────
-- 11. Top Products by Revenue
-- ─────────────────────────────────────────────
SELECT
    product_name,
    ROUND(SUM(sales),2) AS revenue,
    ROUND(SUM(profit),2) AS profit
FROM superstore
GROUP BY product_name
ORDER BY revenue DESC
LIMIT 10;
Category Contribution %
SELECT
    category,
    ROUND(SUM(sales),2) AS revenue,
    ROUND(
        SUM(sales) * 100.0 /
        SUM(SUM(sales)) OVER (),
   
