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

-- Q5: Top 10 product categories by revenue
-- Business question: Which categories bring the most revenue, and what share of the total?
SELECT
    COALESCE(t.product_category_name_english, 'Unknown')      AS category,
    COUNT(DISTINCT o.order_id)                                AS orders,
    ROUND(SUM(i.price), 2)                                    AS revenue,
    ROUND(SUM(i.price) / SUM(SUM(i.price)) OVER () * 100, 1)  AS revenue_share_pct
FROM orders o
JOIN order_items i ON o.order_id = i.order_id
LEFT JOIN products p ON i.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- Q6: Revenue by customer state (delivered orders)
-- Business question: Which states generate the most revenue, and how does order value differ?
SELECT
    c.customer_state                                           AS state,
    COUNT(DISTINCT o.order_id)                                 AS orders,
    COUNT(DISTINCT c.customer_unique_id)                       AS customers,
    ROUND(SUM(i.price), 2)                                     AS revenue,
    ROUND(SUM(i.price) / SUM(SUM(i.price)) OVER () * 100, 1)   AS revenue_share_pct,
    ROUND(SUM(i.price) / COUNT(DISTINCT o.order_id), 2)        AS avg_order_value
FROM orders o
JOIN customers c   ON o.customer_id = c.customer_id
JOIN order_items i ON o.order_id = i.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC;

-- Q7: Delivery performance by customer state (delivered orders)
-- Business question: Which states wait longest for delivery and have the most late orders?
SELECT
    c.customer_state                      AS state,
    COUNT(*)                              AS orders,
    ROUND(AVG(o.delivery_days), 1)        AS avg_delivery_days,
    ROUND(AVG(o.is_late) * 100, 1)        AS late_pct,
    ROUND(AVG(r.review_score), 2)         AS avg_review_score
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
HAVING COUNT(*) >= 100
ORDER BY late_pct DESC;