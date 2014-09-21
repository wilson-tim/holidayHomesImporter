CREATE TABLE [homestay].[imp_property] (
    [place_Id]               BIGINT           NOT NULL,
    [runId]                  INT              NOT NULL,
    [fileId]                 INT              NOT NULL,
    [sourceId]               INT              NOT NULL,
    [name]                   NVARCHAR (255)   NULL,
    [externalId]             BIGINT           NULL,
    [externalURL]            NVARCHAR (2000)  NULL,
    [thumbnailURL]           NVARCHAR (2000)  NULL,
    [description]            NVARCHAR (4000)  NULL,
    [typeOfProperty]         NVARCHAR (255)   NULL,
    [postcode]               NVARCHAR (255)   NULL,
    [cityName]               NVARCHAR (255)   NULL,
    [stateName]              NVARCHAR (255)   NULL,
    [country]                NVARCHAR (255)   NULL,
    [countryCode]            NVARCHAR (10)    NULL,
    [latitude]               DECIMAL (28, 10) NULL,
    [longitude]              DECIMAL (28, 10) NULL,
    [minimumPricePerNight]   DECIMAL (10, 2)  NULL,
    [propertyCurrencyCode]   NVARCHAR (10)    NULL,
    [numberOfProperBedrooms] INT              NULL,
    [numberOfBathrooms]      INT              NULL,
    [maximumNumberOfPeople]  INT              NULL,
    [minimumDaysOfStay]      INT              NULL
);


GO
CREATE CLUSTERED INDEX [CIX_imp_property]
    ON [homestay].[imp_property]([runId] ASC, [fileId] ASC, [place_Id] ASC, [externalId] ASC);

