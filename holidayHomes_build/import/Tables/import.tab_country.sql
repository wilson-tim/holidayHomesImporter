CREATE TABLE [import].[tab_country] (
    [countryNumber] INT            NOT NULL,
    [countryCode3]  NVARCHAR (3)   NOT NULL,
    [countryCode2]  NVARCHAR (2)   NOT NULL,
    [countryName]   NVARCHAR (255) NOT NULL,
    CONSTRAINT [PK_country] PRIMARY KEY CLUSTERED ([countryName] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [UIX_country_code2]
    ON [import].[tab_country]([countryCode2] ASC, [countryName] ASC);

