INSERT INTO analysis.tmp_rfm_recency
WITH orders_with_status AS(
	SELECT user_id, order_ts,
		ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY order_ts DESC) user_number
	FROM analysis.orders o
	JOIN analysis.orderstatuses os ON o.status = os.id
	WHERE key = 'Closed' AND date_part('year', order_ts) >= 2022
), last_order AS (
	SELECT id, 0 AS order_ts_number
	FROM analysis.users
	WHERE id NOT IN (
		SELECT user_id
		FROM orders_with_status
	)
	UNION
	SELECT user_id,
		ROW_NUMBER() OVER(ORDER BY order_ts) as order_ts_number
	FROM orders_with_status
	WHERE user_number = 1
), result_numbers AS (
	SELECT id AS user_id, 
		ROW_NUMBER() OVER(ORDER BY order_ts_number) AS order_ts_number
	FROM last_order
), result AS (
	SELECT user_id, (
		CASE
			WHEN order_ts_number <= (SELECT MAX(order_ts_number) FROM last_order) / 5 THEN 1
			WHEN order_ts_number <= (SELECT MAX(order_ts_number) FROM last_order) * 2 / 5 THEN 2
			WHEN order_ts_number <= (SELECT MAX(order_ts_number) FROM last_order) * 3 / 5 THEN 3
			WHEN order_ts_number <= (SELECT MAX(order_ts_number) FROM last_order) * 4 / 5 THEN 4
			ELSE 5
		END) as recency
	FROM result_numbers
)
SELECT *
FROM result
ORDER BY recency, user_id


