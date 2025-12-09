
-- triggers.sql
USE ecommerce_db;

-- Trigger: after insert order_items -> update inventory and log change
DELIMITER $$
CREATE TRIGGER trg_order_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    -- Ensure inventory is not negative (business logic)
    UPDATE inventory SET quantity = quantity - NEW.quantity WHERE product_id = NEW.product_id;
    -- Insert audit record (simple approach using a log table)
    INSERT INTO inventory_audit (product_id, change_qty, reason, change_time)
        VALUES (NEW.product_id, -NEW.quantity, CONCAT('Order#', NEW.order_id), NOW());
END $$
DELIMITER ;

-- Supporting audit table
CREATE TABLE IF NOT EXISTS inventory_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    change_qty INT,
    reason VARCHAR(255),
    change_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
