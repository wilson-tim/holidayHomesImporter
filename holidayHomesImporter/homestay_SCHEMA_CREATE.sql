USE holidayHomes_build
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'homestay')
	EXEC ('CREATE SCHEMA homestay');
GO

IF OBJECT_ID('homestay.imp_property', N'U') IS NOT NULL
	DROP TABLE homestay.imp_property;
GO

IF OBJECT_ID('homestay.imp_photo', N'U') IS NOT NULL
	DROP TABLE homestay.imp_photo;
GO

IF OBJECT_ID('homestay.imp_amenity', N'U') IS NOT NULL
	DROP TABLE homestay.imp_amenity;
GO

CREATE TABLE [homestay].[imp_property] (
    [place_Id] bigint NOT NULL,
    [runId] int NOT NULL,
    [fileId] int NOT NULL,
    [sourceId] int NOT NULL,
    [name] nvarchar(255),
    [externalId] bigint,
    [externalURL] nvarchar(2000),
    [thumbnailURL] nvarchar(2000),
    [description] nvarchar(4000),
    [typeOfProperty] nvarchar(255),
    [postcode] nvarchar(255),
    [cityName] nvarchar(255),
    [stateName] nvarchar(255),
    [country] nvarchar(255),
    [countryCode] nvarchar(10),
    [latitude] decimal(28,10),
    [longitude] decimal(28,10),
    [minimumPricePerNight] decimal(10,2),
    [propertyCurrencyCode] nvarchar(10),
    [numberOfProperBedrooms] int,
    [numberOfBathrooms] int,
    [maximumNumberOfPeople] int,
    [minimumDaysOfStay] int
);
GO

CREATE CLUSTERED INDEX [CIX_imp_property] ON [homestay].[imp_property]
(
	[runId] ASC,
	[fileId] ASC,
	[place_Id] ASC,
	[externalId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [homestay].[imp_photo] (
    [additional_photos_Id] bigint,
    [place_Id] bigint,
    [photo] nvarchar(2000),
    [runId] int,
    [fileId] int,
    [sourceId] int
);
GO

CREATE CLUSTERED INDEX [CIX_imp_photo] ON [homestay].[imp_photo]
(
	[runId] ASC,
	[fileId] ASC,
	[place_Id] ASC,
	[additional_photos_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

CREATE TABLE [homestay].[imp_amenity] (
    [amenities_Id] bigint,
    [place_Id] bigint,
    [amenity] nvarchar(255),
    [runId] int,
    [fileId] int,
    [sourceId] int
);
GO

CREATE CLUSTERED INDEX [CIX_imp_amenity] ON [homestay].[imp_amenity]
(
	[runId] ASC,
	[fileId] ASC,
	[place_Id] ASC,
	[amenities_Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
