CREATE TABLE [dbo].[tab_propertyCountryLookup] (
    [sourceId]     INT            NOT NULL,
    [externalId]   NVARCHAR (100) NOT NULL,
    [propertyId]   BIGINT         NOT NULL,
    [latitude]     FLOAT (53)     NOT NULL,
    [longitude]    FLOAT (53)     NOT NULL,
    [countryCode2] CHAR (2)       NULL,
    [dateUpdated]  DATETIME       CONSTRAINT [DF_Table_1_createdAt] DEFAULT (getdate()) NULL,
    [updated]      BIT        CONSTRAINT [DF_tab_propertyCountryLookup_updated] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_tab_propertyCountryLookup] PRIMARY KEY CLUSTERED ([sourceId] ASC, [externalId] ASC, [propertyId] ASC)
);

