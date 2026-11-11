create database olist;
use olist;
-- Q1: Orders by status
-- Business question: How many orders are in each status?
SELECT
    order_status,
    COUNT(*) AS total
FROM orders
GROUP BY order_status
ORDER BY total DESC;


-- Q2: Revenue summary for delivered orders
-- Business question: How much revenue do delivered orders generate?
SELECT
    ROUND(SUM(i.price), 2)                              AS revenue,
    ROUND(SUM(i.freight_value), 2)                      AS total_freight,
    COUNT(DISTINCT o.order_id)                          AS total_orders,
    COUNT(*)                                            AS total_items,
    ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered';

-- Q3: Monthly revenue for delivered orders
-- Business question: How do orders and revenue change month by month?
SELECT
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS orders,
    ROUND(SUM(i.price), 2) AS revenue
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;

-- Q4: Month-over-month revenue growth
-- Business question: By what percentage does revenue change from the previous month?
-- Starts from 2017-01 because 2016 has only 3 sparse months, which would give meaningless growth rates.
WITH monthly AS (
    SELECT
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        ROUND(SUM(i.price), 2)                           AS revenue
    FROM orders o
    JOIN order_items i ON o.order_id = i.order_id
    WHERE o.order_status = 'delivered'
      AND o.order_purchase_timestamp >= '2017-01-01'
    GROUP BY order_month
),
with_prev AS (
    SELECT
        order_month,
        revenue,
        LAG(revenue) OVER (ORDER BY order_month) AS prev_revenue
    FROM monthly
)
SELECT
    order_month,
    revenue,
    prev_revenue,
    ROUND((revenue - prev_revenue) / prev_revenue * 100, 1) AS mom_growth_pct
FROM with_prev
ORDER BY order_month;

SELECT MAX(order_purchase_timestamp) FROM orders;

-- Q4B: Why delivered orders stop at Aug 2018
SELECT
    DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS order_month,
    order_status,
    COUNT(*) AS orders
FROM orders
WHERE order_purchase_timestamp >= '2018-08-01'
GROUP BY order_month, order_status
ORDER BY order_month, orders DESC;