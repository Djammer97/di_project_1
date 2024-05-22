INSERT INTO analysis.dm_rfm_segments
SELECT *
FROM analysis.tmp_rfm_recency
JOIN analysis.tmp_rfm_frequency USING(user_id)
JOIN analysis.tmp_rfm_monetary_value USING(user_id)
ORDER BY user_id;

/*
user_id recency frequency monetary_value
0			1		3			4
1			4		3			3
2			2		3			5
3			2		3			3
4			4		3			3
5			5		5			5
6			1		3			5
7			4		2			2
8			1		1			3
9			1		2			2
*/