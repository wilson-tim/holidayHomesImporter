CREATE TABLE [dbo].[tab_property] (
    [propertyId]                            BIGINT          NOT NULL,
    [sourceId]                              INT             NOT NULL,
    [runId]                                 INT             NOT NULL,
    [externalId]                            NVARCHAR (100)  NOT NULL,
    [thumbnailUrl]                          NVARCHAR (2000) NULL,
    [externalURL]                           NVARCHAR (2000) NOT NULL,
    [description]                           NVARCHAR (4000) NULL,
    [name]                                  NVARCHAR (255)  NULL,
    [regionName]                            NVARCHAR (255)  NULL,
    [typeOfProperty]                        NVARCHAR (50)   NULL,
    [postcode]                              NVARCHAR (255)  NULL,
    [regionId]                              INT             NULL,
    [cityId]                                INT             NULL,
    [cityName]                              NVARCHAR (255)  NULL,
    [stateName]                             NVARCHAR (255)  NULL,
    [countryCode]                           NVARCHAR (2)    NULL,
    [latitude]                              FLOAT (53)      NULL,
    [longitude]                             FLOAT (53)      NULL,
    [checkInFrom]                           TIME (7)        NULL,
    [checkOutBefore]                        TIME (7)        NULL,
    [sizeOfSpaceInSqm]                      INT             NULL,
    [sizeOfSpaceInSqft]                     INT             NULL,
    [cancellationPolicy]                    NVARCHAR (255)  NULL,
    [minimumPricePerNight]                  INT             NULL,
    [currencyCode]                          NVARCHAR (3)    NULL,
    [numberOfProperBedrooms]                INT             NULL,
    [numberOfBathrooms]                     INT             NULL,
    [floor]                                 NVARCHAR (255)  NULL,
    [reviewsCount]                          INT             NULL,
    [averageRating]                         FLOAT (53)      NULL,
    [maximumNumberOfPeople]                 INT             NULL,
    [numberOfOtherRoomsWhereGuestsCanSleep] INT             NULL,
    [minimumDaysOfStay]                     INT             NULL,
    [dateCreated]                           DATETIME        NOT NULL,
    [lastUpdated]                           DATETIME        NOT NULL,
    [propertyHashKey]                       VARBINARY (32)  NULL,
    [amenitiesChecksum]                     BIGINT          NULL,
    [photosChecksum]                        BIGINT          NULL,
    [ratesChecksum]                         BIGINT          NULL,
    CONSTRAINT [PK_property] PRIMARY KEY CLUSTERED ([propertyId] ASC)
);

GO

CREATE NONCLUSTERED INDEX [NCI_propertySearch] ON [dbo].[tab_property]
(
	[numberOfProperBedrooms] ASC,
	[countryCode] ASC,
	[typeOfProperty] ASC,
	[cityName] ASC
)
INCLUDE ( 	[propertyId],
	[sourceId],
	[externalId],
	[externalURL],
	[description],
	[name],
	[regionName],
	[latitude],
	[longitude],
	[minimumPricePerNight],
	[currencyCode],
	[averageRating],
	[maximumNumberOfPeople]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

CREATE STATISTICS [_dta_stat_565577053_1_16_10_26_14] ON [dbo].[tab_property]([propertyId], [countryCode], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_1_2_10_16_26_14] ON [dbo].[tab_property]([propertyId], [sourceId], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_14_16_10] ON [dbo].[tab_property]([cityName], [countryCode], [typeOfProperty]);
GO
CREATE STATISTICS [_dta_stat_565577053_2_10_16_26_14] ON [dbo].[tab_property]([sourceId], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_18_1_10_26_14] ON [dbo].[tab_property]([longitude], [propertyId], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_17_1_10_26_14] ON [dbo].[tab_property]([latitude], [propertyId], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_2_18_17_10_16_26_14] ON [dbo].[tab_property]([sourceId], [longitude], [latitude], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_9_1_10_26] ON [dbo].[tab_property]([regionName], [propertyId], [typeOfProperty], [numberOfProperBedrooms]);
GO
CREATE STATISTICS [_dta_stat_565577053_26_1] ON [dbo].[tab_property]([numberOfProperBedrooms], [propertyId]);
GO
CREATE STATISTICS [_dta_stat_565577053_1_2_18_17_10_16_26_14] ON [dbo].[tab_property]([propertyId], [sourceId], [longitude], [latitude], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_1_10_26] ON [dbo].[tab_property]([propertyId], [typeOfProperty], [numberOfProperBedrooms]);
GO
CREATE STATISTICS [_dta_stat_565577053_10_26_14] ON [dbo].[tab_property]([typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_16_1_10_26_14] ON [dbo].[tab_property]([countryCode], [propertyId], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO
CREATE STATISTICS [_dta_stat_565577053_14_1_10_26] ON [dbo].[tab_property]([cityName], [propertyId], [typeOfProperty], [numberOfProperBedrooms]);
GO
CREATE STATISTICS [_dta_stat_565577053_9_16_10_26] ON [dbo].[tab_property]([regionName], [countryCode], [typeOfProperty], [numberOfProperBedrooms]);
GO
CREATE STATISTICS [_dta_stat_565577053_10_16] ON [dbo].[tab_property]([typeOfProperty], [countryCode]);
GO
