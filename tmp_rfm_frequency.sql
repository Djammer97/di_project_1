INSERT INTO analysis.tmp_rfm_frequency
WITH orders_with_amount AS(
	SELECT user_id, 
		COUNT(user_id) as amount
	FROM analysis.orders o
	JOIN analysis.orderstatuses os ON o.status = os.id
	WHERE key = 'Closed' AND date_part('year', order_ts) >= 2022
	GROUP BY user_id
), orders_with_amount_and_numbers AS (
	SELECT *,
		ROW_NUMBER() OVER(ORDER BY amount) as amount_number
	FROM orders_with_amount
)
SELECT user_id, (
	CASE
		WHEN amount_number <= CEIL((SELECT MAX(amount_number) FROM orders_with_amount_and_numbers) / 5) THEN 1
		WHEN amount_number <= CEIL((SELECT MAX(amount_number) FROM orders_with_amount_and_numbers) * 2 / 5) THEN 2
		WHEN amount_number <= CEIL((SELECT MAX(amount_number) FROM orders_with_amount_and_numbers) * 3 / 5) THEN 3
		WHEN amount_number <= CEIL((SELECT MAX(amount_number) FROM orders_with_amount_and_numbers) * 4 / 5) THEN 4
		ELSE 5
	END) as frequency
FROM orders_with_amount_and_numbers
