INSERT INTO analysis.tmp_rfm_monetary_value
WITH orders_with_sum AS(
	SELECT user_id, 
		SUM(payment) as payment
	FROM analysis.orders o
	JOIN analysis.orderstatuses os ON o.status = os.id
	WHERE key = 'Closed' AND date_part('year', order_ts) >= 2022
	GROUP BY user_id
), orders_with_sum_and_numbers AS (
	SELECT *,
		ROW_NUMBER() OVER(ORDER BY payment) as amount_payment
	FROM orders_with_sum
)
SELECT user_id, (
	CASE
		WHEN amount_payment <= CEIL((SELECT MAX(amount_payment) FROM orders_with_sum_and_numbers) / 5) THEN 1
		WHEN amount_payment <= CEIL((SELECT MAX(amount_payment) FROM orders_with_sum_and_numbers) * 2 / 5) THEN 2
		WHEN amount_payment <= CEIL((SELECT MAX(amount_payment) FROM orders_with_sum_and_numbers) * 3 / 5) THEN 3
		WHEN amount_payment <= CEIL((SELECT MAX(amount_payment) FROM orders_with_sum_and_numbers) * 4 / 5) THEN 4
		ELSE 5
	END) as monetary_value
FROM orders_with_sum_and_numbers