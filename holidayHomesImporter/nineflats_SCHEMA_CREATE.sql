USE holidayHomes_build
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'nineflats')
	EXEC ('CREATE SCHEMA nineflats');
GO

IF OBJECT_ID('nineflats.imp_property', N'U') IS NOT NULL
	DROP TABLE [nineflats].[imp_property];
GO

IF OBJECT_ID('nineflats.imp_photo', N'U') IS NOT NULL
	DROP TABLE [nineflats].[imp_photo];
GO

IF OBJECT_ID('nineflats.imp_amenity', N'U') IS NOT NULL
	DROP TABLE [nineflats].[imp_amenity];
GO

CREATE TABLE [nineflats].[imp_property] (
    [property_Id] bigint,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL,
	[name] nvarchar(255),
	[bathroom_type] nvarchar(255),
	[bed_type] nvarchar(255),
	[cancellation_rules] nvarchar(4000),
	[category] nvarchar(255),
	[charge_per_extra_person_limit] decimal(10,2),
	[city] nvarchar(255),
	[cleaning_fee] decimal(10,2),
	[content_language] nvarchar(10),
	[country] nvarchar(255),
	[description] nvarchar(4000),
	[district] nvarchar(255),
	[externalURL] nvarchar(2000),
	[favourites_count] int,
	[featured_photo] nvarchar(2000),
	[id] bigint,
	[instant_bookable] bit,
	[lat] float,
	[lng] float,
	[maximum_nights] int,
	[minimum_nights] int,
	[number_of_bathrooms] int,
	[number_of_bedrooms] int,
	[number_of_beds] int,
	[pets_around] bit,
	[place_type] nvarchar(255),
	[size] int,
	[slug] nvarchar(255),
	[zipcode] nvarchar(255),
	[currency] nvarchar(10),
	[price] decimal(10,2)
);
GO

CREATE TABLE [nineflats].[imp_photo] (
    [property_photos_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL,
    [photo] nvarchar(2000)
);
GO

CREATE TABLE [nineflats].[imp_amenity] (
    [property_amenities_Id] bigint NOT NULL,
    [property_Id] bigint NOT NULL,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL,
    [amenity] nvarchar(255)
);
GO
