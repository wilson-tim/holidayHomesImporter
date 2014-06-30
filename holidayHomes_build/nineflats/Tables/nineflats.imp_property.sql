CREATE TABLE [nineflats].[imp_property] (
    [property_Id]                   BIGINT          NULL,
    [runId]                         INT             NOT NULL,
    [fileId]                        INT             NOT NULL,
    [sourceId]                      INT             NOT NULL,
    [name]                          NVARCHAR (255)  NULL,
    [bathroom_type]                 NVARCHAR (255)  NULL,
    [bed_type]                      NVARCHAR (255)  NULL,
    [cancellation_rules]            NVARCHAR (4000) NULL,
    [category]                      NVARCHAR (255)  NULL,
    [charge_per_extra_person_limit] DECIMAL (10, 2) NULL,
    [city]                          NVARCHAR (255)  NULL,
    [cleaning_fee]                  DECIMAL (10, 2) NULL,
    [content_language]              NVARCHAR (10)   NULL,
    [country]                       NVARCHAR (255)  NULL,
    [description]                   NVARCHAR (4000) NULL,
    [district]                      NVARCHAR (255)  NULL,
    [externalURL]                   NVARCHAR (2000) NULL,
    [favourites_count]              INT             NULL,
    [featured_photo]                NVARCHAR (2000) NULL,
    [id]                            BIGINT          NULL,
    [instant_bookable]              BIT             NULL,
    [lat]                           FLOAT (53)      NULL,
    [lng]                           FLOAT (53)      NULL,
    [maximum_nights]                INT             NULL,
    [minimum_nights]                INT             NULL,
    [number_of_bathrooms]           INT             NULL,
    [number_of_bedrooms]            INT             NULL,
    [number_of_beds]                INT             NULL,
    [pets_around]                   BIT             NULL,
    [place_type]                    NVARCHAR (255)  NULL,
    [size]                          INT             NULL,
    [slug]                          NVARCHAR (255)  NULL,
    [zipcode]                       NVARCHAR (255)  NULL,
    [currency]                      NVARCHAR (10)   NULL,
    [price]                         DECIMAL (10, 2) NULL
);




GO
CREATE CLUSTERED INDEX [CIX_imp_property]
    ON [nineflats].[imp_property]([runId] ASC, [fileId] ASC, [property_Id] ASC, [id] ASC);

