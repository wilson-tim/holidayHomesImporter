CREATE TABLE [holidayHomes].[tab_property] (
    [propertyId]                            BIGINT          IDENTITY (1, 1) NOT NULL,
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
    [dateCreated]                           DATETIME        CONSTRAINT [DF_property_dateCreated] DEFAULT (getdate()) NOT NULL,
    [lastUpdated]                           DATETIME        CONSTRAINT [DF_property_lastUpdated] DEFAULT (getdate()) NOT NULL,
    [propertyHashKey]                       VARBINARY (32)  NULL,
    [amenitiesChecksum]                     BIGINT          NULL,
    [photosChecksum]                        BIGINT          NULL,
    [ratesChecksum]                         BIGINT          NULL,
    CONSTRAINT [PK_property] PRIMARY KEY CLUSTERED ([propertyId] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_tab_property_importHashKeys]
    ON [holidayHomes].[tab_property]([propertyHashKey] ASC, [amenitiesChecksum] ASC, [photosChecksum] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_holidayHomes_tab_property]
    ON [holidayHomes].[tab_property]([sourceId] ASC, [externalId] ASC)
    INCLUDE([propertyId], [ratesChecksum]);

