CREATE TABLE [import].[tab_country] (
    [countryNumber] INT            NOT NULL,
    [countryCode3]  NVARCHAR (3)   NOT NULL,
    [countryCode2]  NVARCHAR (2)   NOT NULL,
    [countryName]   NVARCHAR (255) NOT NULL
);


GO
CREATE CLUSTERED INDEX [CX_import_tab_country]
    ON [import].[tab_country]([countryCode2] ASC, [countryName] ASC);

