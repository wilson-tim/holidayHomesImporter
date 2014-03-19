USE holidayHomes_build
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'flipkey')
	EXEC ('CREATE SCHEMA flipkey');
GO

IF OBJECT_ID('flipkey.imp_property', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_property;
GO

IF OBJECT_ID('flipkey.imp_bathroom', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_bathroom;
GO

IF OBJECT_ID('flipkey.imp_photo', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_photo;
GO

IF OBJECT_ID('flipkey.imp_bedroom', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_bedroom;
GO

IF OBJECT_ID('flipkey.imp_amenity', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_amenity;
GO

IF OBJECT_ID('flipkey.imp_fee', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_fee;
GO

IF OBJECT_ID('flipkey.imp_video', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_video;
GO

IF OBJECT_ID('flipkey.imp_default_rate', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_default_rate;
GO

IF OBJECT_ID('flipkey.imp_rate', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_rate;
GO

IF OBJECT_ID('flipkey.imp_theme', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_theme;
GO

IF OBJECT_ID('flipkey.imp_booked_date', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_booked_date;
GO

IF OBJECT_ID('flipkey.imp_calendar', N'U') IS NOT NULL
	DROP TABLE flipkey.imp_calendar;
GO

CREATE TABLE [flipkey].[imp_property] (
    [property_Id] bigint,
    [detailsCheck_in] nvarchar(255),
    [detailsCheck_out] nvarchar(255),
    [detailsName] nvarchar(255),
    [detailsElder] nvarchar(10),
    [detailsBathroom_count] decimal(10,2),
    [detailsBedroom_count] decimal(10,2),
    [detailsPet] nvarchar(10),
    [detailsUnit_size] nvarchar(255),
    [detailsCurrency] nvarchar(255),
    [detailsHandicap] nvarchar(10),
    [detailsMinimum_stay] decimal(10,2),
    [detailsOccupancy] decimal(10,2),
    [detailsSmoking] nvarchar(10),
    [detailsUrl] nvarchar(2000),
    [detailsUnit_size_units] nvarchar(20),
    [detailsProperty_type] nvarchar(20),
    [detailsChildren] nvarchar(255),
    [propertyDescription] nvarchar(4000),
    [review_count] decimal(10,2),
    [flagsCalendar_export_url] nvarchar(2000),
    [flagsRates_updated] datetime,
    [flagsLast_booked_date] datetime,
    [flagsHas_special] bit,
    [flagsPhotos_updated] datetime,
    [flagsIs_tip] nvarchar(255),
    [flagsCalendar_updated] datetime,
    [flagsAlt_photo_test] nvarchar(255),
    [flagsAlt_pdp_sprite_filename_v2] nvarchar(255),
    [addressCity] nvarchar(255),
    [addressLocation_name] nvarchar(255),
    [addressZip] nvarchar(255),
    [addressAddress1] nvarchar(255),
    [addressAddress2] nvarchar(255),
    [addressPrecision] nvarchar(10),
    [addressLongitude] decimal(10,2),
    [addressShow_exact_address] decimal(10,2),
    [addressState] nvarchar(255),
    [addressNew_location_id] decimal(10,2),
    [addressCountry] nvarchar(255),
    [addressLatitude] decimal(10,2),
    [review_sum] decimal(10,2),
    [review_photos] decimal(10,2),
    [rateUser_day_min_rate] decimal(10,2),
    [rateDay_max_rate] decimal(10,2),
    [rateUser_week_min_rate] decimal(10,2),
    [rateUser_month_max_rate] decimal(10,2),
    [rateWeek_max_rate] decimal(10,2),
    [rateUser_week_max_rate] decimal(10,2),
    [rateUser_month_min_rate] decimal(10,2),
    [rateMonth_max_rate] decimal(10,2),
    [rateMinimum_length] decimal(10,2),
    [rateMonth_min_rate] decimal(10,2),
    [rateUser_day_max_rate] decimal(10,2),
    [rateDay_min_rate] decimal(10,2),
    [rateWeek_min_rate] decimal(10,2),
    [attributesUser_id] decimal(10,2),
    [attributesIs_revgen] nvarchar(255),
    [attributesModified] datetime,
    [attributesService_level_id] decimal(10,2),
    [attributesDirect] nvarchar(255),
    [attributesScore] decimal(10,2),
    [attributesUser_group_id] decimal(10,2),
    [attributesFrontdesk_id] decimal(10,2),
    [attributesProperty_id] decimal(10,2),
    [specialAmt_off_per_night] decimal(10,2),
    [specialAmt_off_per_stay] decimal(10,2),
    [specialCurrency] nvarchar(255),
    [specialDescription] nvarchar(4000),
    [specialTitle] nvarchar(255),
    [specialFree_stuff_title] nvarchar(255),
    [specialNum_free_nights] nvarchar(255),
    [specialOut_of_num_nights] decimal(10,2),
    [specialPct_off_rate] decimal(10,2),
    [specialPublish_start_date] datetime,
    [specialPublish_end_date] datetime,
    [specialRental_start_date] datetime,
    [specialRental_end_date] datetime,
    [specialSpecial_type_description] nvarchar(50),
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_bathroom] (
    [property_bathrooms_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [type] nvarchar(50),
    [description] nvarchar(4000),
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_photo] (
    [property_photos_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [description] nvarchar(4000),
    [has_full] nvarchar(255),
    [base_url] nvarchar(2000),
    [photo_file_name] nvarchar(255),
    [height] decimal(10,2),
    [original_height] decimal(10,2),
    [largest_image_prefix] nvarchar(10),
    [photo_type] nvarchar(255),
    [width] decimal(10,2),
    [original_width] decimal(10,2),
    [order] int,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_bedroom] (
    [property_bedrooms_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [twin_count] int,
    [other_count] int,
    [description] nvarchar(4000),
    [standard_count] int,
    [bunk_count] int,
    [queen_count] int,
    [king_count] int,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_amenity] (
    [property_amenities_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [description] nvarchar(4000),
    [parent_amenity] nvarchar(255),
    [site_amenity] nvarchar(255),
    [order] int,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_fee] (
    [property_fees_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [fee_units] nvarchar(255),
    [required] int,
    [property_fee_type_id] int,
    [name] nvarchar(255),
    [cost] decimal(10,2),
    [type] nvarchar(255),
    [description] nvarchar(4000),
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_video] (
    [property_videos_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [baseurl] nvarchar(2000),
    [description] nvarchar(4000),
    [last_verified] datetime,
    [modified] datetime,
    [order] int,
    [status] nvarchar(255),
    [video_source] nvarchar(255),
    [video_source_id] nvarchar(255),
    [video_source_updated] datetime,
    [video_thumb_filename] nvarchar(255),
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_default_rate] (
    [property_default_rates_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [modified] datetime,
    [minimum_length] decimal(10,2),
    [day_max_rate] decimal(10,2),
    [day_min_rate] decimal(10,2),
    [month_max_rate] decimal(10,2),
    [month_min_rate] decimal(10,2),
    [week_max_rate] decimal(10,2),
    [week_min_rate] decimal(10,2),
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_rate] (
    [property_rates_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL ,
    [weekend_min_rate] decimal(10,2),
    [weeknight_max_rate] decimal(10,2),
    [end_date] datetime,
    [week_max_rate] decimal(10,2),
    [weekend_max_rate] decimal(10,2),
    [start_date] datetime,
    [label] nvarchar(255),
    [weekend_nights] nvarchar(255),
    [per_person_per_stay] decimal(10,2),
    [per_person_per_night] decimal(10,2),
    [minimum_length] decimal(10,2),
    [turn_day] nvarchar(255),
    [month_max_rate] decimal(10,2),
    [per_person_over_amount] decimal(10,2),
    [is_changeover_day_defined] nvarchar(255),
    [weeknight_min_rate] decimal(10,2),
    [changeover_day] nvarchar(255),
    [month_min_rate] decimal(10,2),
    [week_min_rate] decimal(10,2),
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_theme] (
    [property_themes_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [theme_type] nvarchar(10),
    [theme_description] nvarchar(20),
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_booked_date] (
    [property_booked_dates_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [booked_date] datetime,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO

CREATE TABLE [flipkey].[imp_calendar] (
    [property_calendars_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [property_calendar] datetime,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL
)
GO
