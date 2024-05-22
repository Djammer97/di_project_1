CREATE OR REPLACE VIEW analysis.orders AS
SELECT order_id, order_ts, user_id, bonus_payment, payment, cost, bonus_grant, status_id as status
FROM production.orders
JOIN production.orderstatuslog USING(order_id)