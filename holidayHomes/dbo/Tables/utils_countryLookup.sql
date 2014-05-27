CREATE TABLE [dbo].[utils_countryLookup] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [iso2]             CHAR (2)       NOT NULL,
    [longName]         NVARCHAR (100) NOT NULL,
    [searchTerm]       NVARCHAR (100) NOT NULL,
    [centralLatitude]  FLOAT (53)     NULL,
    [centralLongitude] FLOAT (53)     NULL,
    [swLatitude]       FLOAT (53)     NULL,
    [swLongitude]      FLOAT (53)     NULL,
    [neLatitude]       FLOAT (53)     NULL,
    [neLongitude]      FLOAT (53)     NULL,
    [radius]           INT            CONSTRAINT [DF_utils_countryLookup_radius] DEFAULT ((0)) NOT NULL,
    [createdDate]      DATETIME       CONSTRAINT [DF_utils_countryLookup_createdDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_utils_countryLookup] PRIMARY KEY CLUSTERED ([id] ASC)
);



