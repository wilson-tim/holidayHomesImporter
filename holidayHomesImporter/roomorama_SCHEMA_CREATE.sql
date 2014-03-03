USE holidayHomes_build
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'roomorama')
	EXEC ('CREATE SCHEMA roomorama');
GO

IF OBJECT_ID('roomorama.imp_property', N'U') IS NOT NULL DROP TABLE roomorama.imp_property;

IF OBJECT_ID('roomorama.imp_photo', N'U') IS NOT NULL DROP TABLE roomorama.imp_photo;

IF OBJECT_ID('roomorama.imp_amenity', N'U') IS NOT NULL DROP TABLE roomorama.imp_amenity;

CREATE TABLE [roomorama].[imp_property] (
    [room_Id] numeric(20,0),
    [id] decimal(28,10),
    [title] nvarchar(255),
    [type] nvarchar(255),
    [subtype] nvarchar(255),
    [url] nvarchar(2000),
    [num-rooms] decimal(28,10),
    [num-bathrooms] decimal(28,10),
    [max-guests] decimal(28,10),
    [min-stay] decimal(28,10),
    [floor] nvarchar(10),
    [num-double-beds] decimal(28,10),
    [num-single-beds] decimal(28,10),
    [num-sofa-beds] decimal(28,10),
    [surface] decimal(28,10),
    [price] decimal(28,10),
    [tax-rate] decimal(28,10),
    [extra-charges] decimal(28,10),
    [currency-code] nvarchar(255),
    [currency-display] nvarchar(255),
    [description] nvarchar(4000),
    [city] nvarchar(255),
    [country-code] nvarchar(255),
    [lat] decimal(28,10),
    [lng] decimal(28,10),
    [amenities] nvarchar(2000),
    [smoking] bit,
    [pets] bit,
    [children] bit,
    [cleaningAvailable] bit,
    [cleaningRate] nvarchar(20),
    [cleaningRequired] bit,
    [airport-pickupAvailable] bit,
    [airport-pickupRate] nvarchar(20),
    [car-rentalAvailable] bit,
    [car-rentalRate] nvarchar(20),
    [conciergeAvailable] bit,
    [conciergeRate] nvarchar(20),
    [check-in-time] nvarchar(255),
    [check-out-time] nvarchar(255),
    [check-in-instructions] nvarchar(4000),
    [cancellation-policy] nvarchar(255),
    [multi-unit] bit,
    [instantly-bookable] bit,
    [created-at] nvarchar(20),
    [updated-at] nvarchar(20),
    [calendar-updated-at] nvarchar(20),
    [security-deposit] nvarchar(4000),
    [units] nvarchar(4000),
    [hostId] decimal(28,10),
    [hostDisplay] nvarchar(255),
    [hostCertified] bit,
    [hostUrl] nvarchar(2000),
    [runId] int,
    [fileId] int,
    [sourceId] int,
	[periodType] nvarchar(255)
)


CREATE TABLE [roomorama].[imp_photo] (
    [images_Id] numeric(20,0),
    [room_Id] numeric(20,0),
    [caption] nvarchar(255),
    [position] decimal(28,10),
    [imageUrl] nvarchar(2000),
    [runId] int,
    [fileId] int,
    [sourceId] int
)

CREATE TABLE [roomorama].[imp_amenity] (
    [id] decimal(28,10),
    [amenityValue] nvarchar(50),
    [runId] int,
    [fileId] int,
    [sourceId] int
)

