USE holidayHomes_build
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'flipkey')
	EXEC ('CREATE SCHEMA flipkey');
GO

--IF OBJECT_ID('flipkey.imp_property') IS NOT NULL DROP TABLE flipkey.imp_property;
IF OBJECT_ID('flipkey.imp_property', N'U') IS NOT NULL DROP TABLE flipkey.imp_property;

--IF OBJECT_ID('flipkey.imp_bathroom') IS NOT NULL DROP TABLE flipkey.imp_bathroom;
IF OBJECT_ID('flipkey.imp_bathroom', N'U') IS NOT NULL DROP TABLE flipkey.imp_bathroom;

CREATE TABLE flipkey.imp_bathroom
( sourceId INT NOT NULL
, runId INT NOT NULL
, fileId INT NOT NULL
, property_Id INT NOT NULL
, [type] NVARCHAR(255) NOT NULL
, [description] NVARCHAR(4000) NOT NULL
);

CREATE TABLE flipkey.imp_property
( sourceId INT NOT NULL
, runId INT NOT NULL
, fileId INT NOT NULL
, property_Id	BIGINT
, city	NVARCHAR(255)
, zip	NVARCHAR(255)
, address1	NVARCHAR(255)
, address2	NVARCHAR(255)
, longitude	DECIMAL(10,2)
, [precision]	NVARCHAR(255)
, show_exact_address	DECIMAL(10,2)
, [state]	NVARCHAR(255)
, subregion	NVARCHAR(255)
, country	NVARCHAR(255)
, latitude	DECIMAL(10,2)
, review_count	DECIMAL(10,2)
, review_photos	DECIMAL(10,2)
, review_sum	DECIMAL(10,2)
, check_in	NVARCHAR(255)
, check_out	NVARCHAR(255)
, name	NVARCHAR(255)
, bathroom_count	DECIMAL(10,2)
, bedroom_count	DECIMAL(10,2)
, currency	NVARCHAR(255)
, elder	NVARCHAR(255)
, handicap	NVARCHAR(255)
, minimum_stay	DECIMAL(10,2)
, occupancy	DECIMAL(10,2)
, pet	NVARCHAR(255)
, smoking	NVARCHAR(255)
, unit_size	NVARCHAR(255)
, url	NVARCHAR(2000)
, unit_size_units	NVARCHAR(255)
, property_type	NVARCHAR(255)
, children	NVARCHAR(255)
, [user_id]	DECIMAL(10,2)
, modified	DATETIME
, score	NVARCHAR(255)
, user_group_id	DECIMAL(10,2)
, frontdesk_id	DECIMAL(10,2)
, rates_updated	DATETIME
, last_booked_date	DATETIME
, has_special	DECIMAL(10,2)
, photos_updated	DATETIME
, calendar_updated	DATETIME
, day_max_rate	DECIMAL(10,2)
, day_min_rate	DECIMAL(10,2)
, minimum_length	DECIMAL(10,2)
, month_max_rate	DECIMAL(10,2)
, month_min_rate	DECIMAL(10,2)
, week_max_rate	NVARCHAR(255)
, week_min_rate	DECIMAL(10,2)
, user_day_max_rate	DECIMAL(10,2)
, user_day_min_rate	DECIMAL(10,2)
, user_month_max_rate	DECIMAL(10,2)
, user_month_min_rate	DECIMAL(10,2)
, user_week_max_rate	NVARCHAR(255)
, user_week_min_rate	NVARCHAR(255)
, amt_off_per_night	DECIMAL(10,2)
, amt_off_per_stay	DECIMAL(10,2)
, property_special_currency	NVARCHAR(255)
, property_special_description	NVARCHAR(4000)
, title	NVARCHAR(255)
, free_stuff_title	NVARCHAR(255)
, num_free_nights	NVARCHAR(255)
, out_of_num_nights	DECIMAL(10,2)
, pct_off_rate	DECIMAL(10,2)
, publish_start_date	DATETIME
, publish_end_date	DATETIME
, rental_start_date	DATETIME
, rental_end_date	DATETIME
, special_type_description	NVARCHAR(4000)
, propertyType	NVARCHAR(255)
, propertyDescription	NVARCHAR(4000)
);

