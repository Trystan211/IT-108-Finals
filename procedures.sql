
-- procedures.sql
USE ecommerce_db;

-- Procedure to add a new order (creates order, items, updates inventory, computes total)
DELIMITER $$
CREATE PROCEDURE add_order (
    IN p_customer_id INT,
    IN p_items JSON, -- JSON array of {"product_id":X,"quantity":Y,"unit_price":Z}
    OUT p_order_id INT
)
BEGIN
    DECLARE v_total DECIMAL(12,2) DEFAULT 0;
    DECLARE v_pid INT;
    DECLARE v_qty INT;
    DECLARE v_price DECIMAL(10,2);
    DECLARE i INT DEFAULT 0;
    DECLARE n INT;

    -- create order
    INSERT INTO orders (customer_id, total_amount) VALUES (p_customer_id,0);
    SET p_order_id = LAST_INSERT_ID();

    SET n = JSON_LENGTH(p_items);
    WHILE i < n DO
        SET v_pid = JSON_EXTRACT(p_items, CONCAT('$[', i, '].product_id'));
        SET v_qty = JSON_EXTRACT(p_items, CONCAT('$[', i, '].quantity'));
        SET v_price = JSON_EXTRACT(p_items, CONCAT('$[', i, '].unit_price'));
        -- insert order item
        INSERT INTO order_items (order_id, product_id, quantity, unit_price)
            VALUES (p_order_id, v_pid, v_qty, v_price);
        -- decrement inventory
        UPDATE inventory SET quantity = quantity - v_qty WHERE product_id = v_pid;
        SET v_total = v_total + (v_price * v_qty);
        SET i = i + 1;
    END WHILE;

    -- update order total
    UPDATE orders SET total_amount = v_total WHERE order_id = p_order_id;
END $$
DELIMITER ;

-- Procedure to compute customer lifetime value (total spent)
DELIMITER $$
CREATE PROCEDURE compute_customer_ltv (IN p_customer_id INT, OUT p_ltv DECIMAL(12,2))
BEGIN
    SELECT IFNULL(SUM(total_amount),0) INTO p_ltv FROM orders WHERE customer_id = p_customer_id;
END $$
DELIMITER ;
