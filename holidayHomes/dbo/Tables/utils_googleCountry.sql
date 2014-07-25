CREATE TABLE [dbo].[utils_googleCountry] (
    [countryNumber] INT            NOT NULL,
    [countryCode3]  NVARCHAR (3)   NOT NULL,
    [countryCode2]  NVARCHAR (2)   NOT NULL,
    [countryName]   NVARCHAR (255) NOT NULL,
    CONSTRAINT [PK_country] PRIMARY KEY CLUSTERED ([countryName] ASC)
);

