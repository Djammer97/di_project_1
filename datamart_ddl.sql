CREATE TABLE analysis.dm_rfm_segments(
	user_id int4 NOT NULL,
	recency smallint NOT NULL,
	frequency smallint NOT NULL,
	monetary_value smallint NOT NULL,
	CONSTRAINT dm_rfm_segments_recency_check CHECK (recency >= 1 AND recency <= 5),
	CONSTRAINT dm_rfm_segments_frequency_check CHECK (frequency >= 1 AND frequency <= 5),
	CONSTRAINT dm_rfm_segments_monetary_value_check CHECK (monetary_value >= 1 AND monetary_value <= 5) 
)

