
-- schema.sql
-- E-Commerce Sales & Inventory System (MySQL)
-- Tables: customers, categories, products, inventory, orders, order_items, payments, shipments

DROP DATABASE IF EXISTS ecommerce_db;
CREATE DATABASE ecommerce_db;
USE ecommerce_db;

-- Customers
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- Products
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(64) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
        ON DELETE SET NULL ON UPDATE CASCADE
);

-- Inventory (separate table to track stock and warehouse)
CREATE TABLE inventory (
    inventory_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 0 CHECK (quantity >= 0),
    warehouse_location VARCHAR(100),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

-- Orders
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING','PROCESSING','SHIPPED','DELIVERED','CANCELLED') DEFAULT 'PENDING',
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
        ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Order items (line items)
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- Payments
CREATE TABLE payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
    method ENUM('CREDIT_CARD','PAYPAL','BANK_TRANSFER','CASH') NOT NULL,
    status ENUM('AUTHORIZED','CAPTURED','REFUNDED','FAILED') DEFAULT 'AUTHORIZED',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Shipments
CREATE TABLE shipments (
    shipment_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    shipped_date TIMESTAMP,
    carrier VARCHAR(100),
    tracking_number VARCHAR(200),
    status ENUM('PENDING','IN_TRANSIT','DELIVERED','RETURNED') DEFAULT 'PENDING',
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Example indexes (at least 2)
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_inventory_product ON inventory(product_id);

-- Sample data 
INSERT INTO categories (name, description) VALUES
('Electronics', 'Gadgets, devices, tech accessories'),
('Apparel', 'Clothing and fashion items'),
('Home & Kitchen', 'Appliances and home essentials'),
('Sports', 'Sports gear and equipment'),
('Books', 'Printed and digital reading materials');

INSERT INTO products (sku, name, category_id, price, active) VALUES
('SKU-1001', 'Wireless Mouse', 1, 19.99, TRUE),
('SKU-1002', 'Mechanical Keyboard', 1, 79.99, TRUE),
('SKU-1003', 'USB-C Charger', 1, 14.50, TRUE),
('SKU-2001', 'Graphic T-Shirt', 2, 12.99, TRUE),
('SKU-2002', 'Hoodie Jacket', 2, 34.99, TRUE),
('SKU-3001', 'Air Fryer', 3, 89.99, TRUE),
('SKU-3002', 'Blender MaxPro', 3, 49.50, TRUE),
('SKU-4001', 'Basketball', 4, 22.99, TRUE),
('SKU-4002', 'Treadmill Mat', 4, 29.99, TRUE),
('SKU-5001', 'Hardbound Novel', 5, 15.00, TRUE);

INSERT INTO customers (first_name, last_name, email, phone) VALUES
('Juan', 'Dela Cruz', 'juan@example.com', '09171234567'),
('Maria', 'Santos', 'maria@example.com', '09181234567'),
('Carlos', 'Reyes', 'carlos.reyes@example.com', '09191234567'),
('Ana', 'Villanueva', 'ana.v@example.com', '09201234567'),
('Lara', 'Mendoza', 'lara.m@example.com', '09211234567');

INSERT INTO inventory (product_id, quantity, warehouse_location) VALUES
(1, 100, 'WH-A1'),
(2, 75, 'WH-A1'),
(3, 200, 'WH-A2'),
(4, 180, 'WH-B1'),
(5, 120, 'WH-B1'),
(6, 90, 'WH-C1'),
(7, 60, 'WH-C1'),
(8, 150, 'WH-D1'),
(9, 40, 'WH-D1'),
(10, 300, 'WH-E1');

INSERT INTO orders (customer_id, status, total_amount) VALUES
(1, 'PENDING', 39.98),
(2, 'PROCESSING', 89.99),
(3, 'SHIPPED', 47.98),
(4, 'DELIVERED', 134.49),
(5, 'CANCELLED', 12.99);

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
-- Order 1: Juan
(1, 1, 2, 19.99),
-- Order 2: Maria
(2, 6, 1, 89.99),
-- Order 3: Carlos
(3, 3, 1, 14.50),
(3, 4, 1, 12.99),
-- Order 4: Ana
(4, 2, 1, 79.99),
(4, 5, 1, 34.99),
(4, 10, 1, 15.00),
-- Order 5: Lara (cancelled)
(5, 4, 1, 12.99);

INSERT INTO payments (order_id, amount, method, status) VALUES
(1, 39.98, 'CREDIT_CARD', 'CAPTURED'),
(2, 89.99, 'PAYPAL', 'CAPTURED'),
(3, 47.98, 'BANK_TRANSFER', 'CAPTURED'),
(4, 134.49, 'CASH', 'CAPTURED'),
(5, 12.99, 'CREDIT_CARD', 'REFUNDED');

INSERT INTO shipments (order_id, shipped_date, carrier, tracking_number, status) VALUES
(1, NULL, NULL, NULL, 'PENDING'),
(2, NOW(), 'LBC Express', 'LBC123456789', 'IN_TRANSIT'),
(3, NOW(), 'J&T Express', 'JT543210987', 'DELIVERED'),
(4, NOW(), 'Ninja Van', 'NV987654321', 'DELIVERED'),
(5, NULL, NULL, NULL, 'RETURNED');
