INSERT INTO analysis.tmp_rfm_monetary_value
WITH orders_with_sum AS(
	SELECT user_id, 
		SUM(payment) as payment
	FROM analysis.orders o
	JOIN analysis.orderstatuses os ON o.status = os.id
	WHERE key = 'Closed' AND date_part('year', order_ts) >= 2022
	GROUP BY user_id
), orders_with_sum_and_numbers AS (
	SELECT id as user_id, 0 as amount_payment
	FROM users 
	WHERE id NOT IN (
		SELECT user_id
		FROM orders_with_sum)
	UNION
	SELECT user_id,
		ROW_NUMBER() OVER(ORDER BY payment) as amount_payment
	FROM orders_with_sum
), result_number AS (
	SELECT user_id, 
		ROW_NUMBER() OVER(ORDER BY amount_payment) as amount_payment
	FROM orders_with_sum_and_numbers
), result AS (
	SELECT user_id, (
		CASE
			WHEN amount_payment <= (SELECT MAX(amount_payment) FROM orders_with_sum_and_numbers) / 5 THEN 1
			WHEN amount_payment <= (SELECT MAX(amount_payment) FROM orders_with_sum_and_numbers) * 2 / 5 THEN 2
			WHEN amount_payment <= (SELECT MAX(amount_payment) FROM orders_with_sum_and_numbers) * 3 / 5 THEN 3
			WHEN amount_payment <= (SELECT MAX(amount_payment) FROM orders_with_sum_and_numbers) * 4 / 5 THEN 4
			ELSE 5
		END) as monetary_value
	FROM orders_with_sum_and_numbers
) 
SELECT *
FROM result
ORDER BY monetary_value, user_id
