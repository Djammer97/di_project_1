INSERT INTO analysis.tmp_rfm_recency
WITH orders_with_status AS(
	SELECT user_id, order_ts, key, 
		ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY order_ts DESC) user_number
	FROM analysis.orders o
	JOIN analysis.orderstatuses os ON o.status = os.id
	WHERE key = 'Closed' AND date_part('year', order_ts) >= 2022
), last_order AS (
	SELECT *,
		ROW_NUMBER() OVER(ORDER BY order_ts) as order_ts_number
	FROM orders_with_status
	WHERE user_number = 1
)
SELECT user_id, (
	CASE
		WHEN order_ts_number <= CEIL((SELECT MAX(order_ts_number) FROM last_order) / 5) THEN 1
		WHEN order_ts_number <= CEIL((SELECT MAX(order_ts_number) FROM last_order) * 2 / 5) THEN 2
		WHEN order_ts_number <= CEIL((SELECT MAX(order_ts_number) FROM last_order) * 3 / 5) THEN 3
		WHEN order_ts_number <= CEIL((SELECT MAX(order_ts_number) FROM last_order) * 4 / 5) THEN 4
		ELSE 5
	END) as recency
FROM last_order
