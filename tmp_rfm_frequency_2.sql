INSERT INTO analysis.tmp_rfm_frequency
WITH orders_with_amount AS(
	SELECT user_id, 
		COUNT(user_id) as amount
	FROM analysis.orders o
	JOIN analysis.orderstatuses os ON o.status = os.id
	WHERE key = 'Closed' AND date_part('year', order_ts) >= 2022
	GROUP BY user_id
), orders_with_amount_and_numbers AS (
	SELECT id as user_id, 0 as amount_number
	FROM users
	WHERE id NOT IN (
		SELECT user_id 
		FROM orders_with_amount
	)
	UNION
	SELECT user_id,
		ROW_NUMBER() OVER(ORDER BY amount) as amount_number
	FROM orders_with_amount
), result_number AS (
	SELECT user_id,
		ROW_NUMBER() OVER(ORDER BY amount_number) as amount_number
	FROM orders_with_amount_and_numbers
), result AS (
	SELECT user_id, (
		CASE
			WHEN amount_number <= (SELECT MAX(amount_number) FROM orders_with_amount_and_numbers) / 5 THEN 1
			WHEN amount_number <= (SELECT MAX(amount_number) FROM orders_with_amount_and_numbers) * 2 / 5 THEN 2
			WHEN amount_number <= (SELECT MAX(amount_number) FROM orders_with_amount_and_numbers) * 3 / 5 THEN 3
			WHEN amount_number <= (SELECT MAX(amount_number) FROM orders_with_amount_and_numbers) * 4 / 5 THEN 4
			ELSE 5
		END) as frequency
	FROM orders_with_amount_and_numbers
) 
SELECT *
FROM result
ORDER BY frequency, user_id

