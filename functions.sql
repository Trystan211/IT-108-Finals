
-- functions.sql
USE ecommerce_db;

-- Function to compute late fee based on days late
DELIMITER $$
CREATE FUNCTION fn_compute_late_fee(p_amount DECIMAL(10,2), p_days_late INT)
RETURNS DECIMAL(10,2) DETERMINISTIC
BEGIN
    DECLARE v_fee DECIMAL(10,2);
    IF p_days_late <= 0 THEN
        SET v_fee = 0;
    ELSEIF p_days_late <= 7 THEN
        SET v_fee = p_amount * 0.02; -- 2%
    ELSE
        SET v_fee = p_amount * 0.05; -- 5%
    END IF;
    RETURN ROUND(v_fee,2);
END $$
DELIMITER ;
