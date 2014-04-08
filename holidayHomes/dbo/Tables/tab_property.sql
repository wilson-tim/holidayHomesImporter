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
    ON [dbo].[tab_property]
(
	[sourceId] ASC,
	[maximumNumberOfPeople] ASC,
	[longitude] ASC,
	[latitude] ASC,
	[typeOfProperty] ASC,
	[numberOfProperBedrooms] ASC,
	[countryCode] ASC,
	[cityName] ASC,
	[currencyCode] ASC
)
INCLUDE
(
 	[propertyId],
	[externalId],
	[thumbnailUrl],
	[externalURL],
	[description],
	[name],
	[regionName],
	[minimumPricePerNight],
	[averageRating]
) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY]
GO
