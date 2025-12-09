
-- sample_queries.sql
USE ecommerce_db;

-- 1) JOIN query: Get order with customer and total
SELECT o.order_id, o.order_date, CONCAT(c.first_name,' ',c.last_name) AS customer_name, o.total_amount
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2025-01-01'
ORDER BY o.order_date DESC;

-- 2) JOIN query with aggregate: top-selling products
SELECT p.product_id, p.name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY total_sold DESC
LIMIT 10;

-- 3) Subquery: customers who have spent more than average order total
SELECT customer_id, CONCAT(first_name,' ',last_name) AS customer_name, 
    (SELECT SUM(total_amount) FROM orders WHERE customer_id = c.customer_id) AS total_spent
FROM customers c
WHERE (SELECT SUM(total_amount) FROM orders WHERE customer_id = c.customer_id) >
    (SELECT AVG(total_amount) FROM orders);

-- 4) Aggregate with HAVING (monthly revenue)
SELECT DATE_FORMAT(order_date,'%Y-%m') AS month, SUM(total_amount) AS revenue
FROM orders
GROUP BY month
HAVING revenue > 1000
ORDER BY month DESC;

-- 5) Window function (MySQL 8+): running total of orders per day
SELECT order_date,
       total_amount,
       SUM(total_amount) OVER (ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_total
FROM orders
ORDER BY order_date;

-- 6) Query with sorting and filtering (products low in stock)
SELECT p.product_id, p.name, i.quantity, i.warehouse_location
FROM products p
JOIN inventory i ON p.product_id = i.product_id
WHERE i.quantity < 20 AND p.active = 1
ORDER BY i.quantity ASC, p.name;
