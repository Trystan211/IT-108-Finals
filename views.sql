
USE ecommerce_db;

CREATE OR REPLACE VIEW view_active_products AS
SELECT p.product_id, p.name, p.price, i.quantity, i.warehouse_location
FROM products p
JOIN inventory i ON p.product_id = i.product_id
WHERE p.active = 1;

CREATE OR REPLACE VIEW view_top_selling AS
SELECT p.product_id, p.name, SUM(oi.quantity) AS total_sold
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY total_sold DESC;
