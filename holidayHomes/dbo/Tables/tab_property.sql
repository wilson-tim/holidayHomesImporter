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

CREATE NONCLUSTERED INDEX [NCI_propertyAreaSearch]
    ON [dbo].[tab_property]([sourceId] ASC, [longitude] ASC, [latitude] ASC, [typeOfProperty] ASC, [countryCode] ASC, [numberOfProperBedrooms] ASC, [regionName] ASC, [currencyCode] ASC)
    INCLUDE([propertyId], [externalId], [thumbnailUrl], [externalURL], [description], [name], [cityName], [minimumPricePerNight], [averageRating], [maximumNumberOfPeople]);
GO

CREATE NONCLUSTERED INDEX [NCI_propertySearch]
    ON [dbo].[tab_property]([sourceId] ASC, [typeOfProperty] ASC, [countryCode] ASC, [numberOfProperBedrooms] ASC, [regionName] ASC, [currencyCode] ASC)
    INCLUDE([propertyId], [externalId], [thumbnailUrl], [externalURL], [description], [name], [cityName], [latitude], [longitude], [minimumPricePerNight], [averageRating], [maximumNumberOfPeople]);
GO

CREATE STATISTICS [_dta_stat_565577053_1_10_26]
    ON [dbo].[tab_property]([propertyId], [typeOfProperty], [numberOfProperBedrooms]);
GO

CREATE STATISTICS [_dta_stat_565577053_1_16_10_26_14]
    ON [dbo].[tab_property]([propertyId], [countryCode], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_1_2_10_16_26_14]
    ON [dbo].[tab_property]([propertyId], [sourceId], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_1_2_10_16_26_9_25]
    ON [dbo].[tab_property]([propertyId], [sourceId], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [regionName], [currencyCode]);
GO

CREATE STATISTICS [_dta_stat_565577053_1_2_18_17_10_16_26_14]
    ON [dbo].[tab_property]([propertyId], [sourceId], [longitude], [latitude], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_1_2_18_17_10_16_26_9_25]
    ON [dbo].[tab_property]([propertyId], [sourceId], [longitude], [latitude], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [regionName], [currencyCode]);
GO

CREATE STATISTICS [_dta_stat_565577053_10_16]
    ON [dbo].[tab_property]([typeOfProperty], [countryCode]);
GO

CREATE STATISTICS [_dta_stat_565577053_10_25_26_14]
    ON [dbo].[tab_property]([typeOfProperty], [currencyCode], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_10_26_14]
    ON [dbo].[tab_property]([typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_14_1_10_26]
    ON [dbo].[tab_property]([cityName], [propertyId], [typeOfProperty], [numberOfProperBedrooms]);
GO

CREATE STATISTICS [_dta_stat_565577053_14_16_10]
    ON [dbo].[tab_property]([cityName], [countryCode], [typeOfProperty]);
GO

CREATE STATISTICS [_dta_stat_565577053_14_25_10]
    ON [dbo].[tab_property]([cityName], [currencyCode], [typeOfProperty]);
GO

CREATE STATISTICS [_dta_stat_565577053_14_25_16_10]
    ON [dbo].[tab_property]([cityName], [currencyCode], [countryCode], [typeOfProperty]);
GO

CREATE STATISTICS [_dta_stat_565577053_16_1_10_26_14]
    ON [dbo].[tab_property]([countryCode], [propertyId], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_16_10_26_14]
    ON [dbo].[tab_property]([countryCode], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_16_25_10_26_14]
    ON [dbo].[tab_property]([countryCode], [currencyCode], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_17_1_10_26_14]
    ON [dbo].[tab_property]([latitude], [propertyId], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_17_25_10_26_14]
    ON [dbo].[tab_property]([latitude], [currencyCode], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_18_1_10_26_14]
    ON [dbo].[tab_property]([longitude], [propertyId], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_18_25_10_26_14]
    ON [dbo].[tab_property]([longitude], [currencyCode], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_2_10_16_26_14]
    ON [dbo].[tab_property]([sourceId], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_2_18_17_10_16_26_14]
    ON [dbo].[tab_property]([sourceId], [longitude], [latitude], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_25_1_10_26_14]
    ON [dbo].[tab_property]([currencyCode], [propertyId], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_25_1_16_10_26_14]
    ON [dbo].[tab_property]([currencyCode], [propertyId], [countryCode], [typeOfProperty], [numberOfProperBedrooms], [cityName]);
GO

CREATE STATISTICS [_dta_stat_565577053_25_2_10_16_26_9]
    ON [dbo].[tab_property]([currencyCode], [sourceId], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [regionName]);
GO

CREATE STATISTICS [_dta_stat_565577053_25_2_18_17_10_16_26_9]
    ON [dbo].[tab_property]([currencyCode], [sourceId], [longitude], [latitude], [typeOfProperty], [countryCode], [numberOfProperBedrooms], [regionName]);
GO

CREATE STATISTICS [_dta_stat_565577053_26_1]
    ON [dbo].[tab_property]([numberOfProperBedrooms], [propertyId]);
GO

CREATE STATISTICS [_dta_stat_565577053_26_25]
    ON [dbo].[tab_property]([numberOfProperBedrooms], [currencyCode]);
GO

CREATE STATISTICS [_dta_stat_565577053_9_1_10_26]
    ON [dbo].[tab_property]([regionName], [propertyId], [typeOfProperty], [numberOfProperBedrooms]);
GO

CREATE STATISTICS [_dta_stat_565577053_9_16_10_26]
    ON [dbo].[tab_property]([regionName], [countryCode], [typeOfProperty], [numberOfProperBedrooms]);
GO

CREATE STATISTICS [_dta_stat_565577053_9_25_10_26]
    ON [dbo].[tab_property]([regionName], [currencyCode], [typeOfProperty], [numberOfProperBedrooms]);
GO

CREATE STATISTICS [_dta_stat_565577053_9_25_16_10_26]
    ON [dbo].[tab_property]([regionName], [currencyCode], [countryCode], [typeOfProperty], [numberOfProperBedrooms]);
GO

