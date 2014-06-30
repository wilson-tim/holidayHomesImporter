CREATE TABLE [dbo].[utils_relatedCountryLookup] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [countryLookupId] INT            NOT NULL,
    [name]            NVARCHAR (100) NOT NULL,
    [latitude]        FLOAT (53)     NULL,
    [longitude]       FLOAT (53)     NULL,
    [createdDate]     DATETIME       CONSTRAINT [DF_utils_relatedCountryLookup_createdDate] DEFAULT (getdate()) NULL,
    [countryCode]     NVARCHAR (2)   NULL,
    CONSTRAINT [PK_utils_relatedCountryLookup] PRIMARY KEY CLUSTERED ([Id] ASC)
);



