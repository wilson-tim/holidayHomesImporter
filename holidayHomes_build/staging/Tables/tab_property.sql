CREATE TABLE [staging].[tab_property] (
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
    [dateCreated]                           DATETIME        CONSTRAINT [DF_staging_tab_property_dateCreated] DEFAULT (getdate()) NOT NULL,
    [lastUpdated]                           DATETIME        CONSTRAINT [DF_staging_tab_property_lastUpdated] DEFAULT (getdate()) NOT NULL,
    [propertyHashKey]                       VARBINARY (32)  NULL,
    [amenitiesChecksum]                     BIGINT          NULL,
    [photosChecksum]                        BIGINT          NULL,
    [ratesChecksum]                         BIGINT          NULL,
    CONSTRAINT [PK_staging_tab_property] PRIMARY KEY CLUSTERED ([sourceId] ASC, [externalId] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_staging_tab_property_importHashKeys]
    ON [staging].[tab_property]([propertyHashKey] ASC, [amenitiesChecksum] ASC, [photosChecksum] ASC, [ratesChecksum] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tab_property_merge_rates]
    ON [staging].[tab_property]([sourceId] ASC, [externalId] ASC)
    INCLUDE([ratesChecksum]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tab_property_merge_photos]
    ON [staging].[tab_property]([sourceId] ASC, [externalId] ASC)
    INCLUDE([photosChecksum]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tab_property_merge_amenities]
    ON [staging].[tab_property]([sourceId] ASC, [externalId] ASC)
    INCLUDE([amenitiesChecksum]);

