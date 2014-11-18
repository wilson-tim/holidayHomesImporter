CREATE TABLE [dbo].[utils_roomoramaLocations] (
    [id]               INT            NOT NULL,
    [currency_code]    NVARCHAR (10)  NULL,
    [currency_display] NVARCHAR (10)  NULL,
    [long_name]        NVARCHAR (255) NULL,
    [name]             NVARCHAR (255) NULL,
    [parent_id]        INT            NULL,
    [searchable]       BIT            NULL,
    [type]             NVARCHAR (255) NULL,
    [url]              NVARCHAR (255) NULL,
    [url_name]         NVARCHAR (255) NULL,
    [url_path]         NVARCHAR (255) NULL,
    [searchableName]   NVARCHAR (255) NULL,
    [destination_id]   INT            NULL,
    CONSTRAINT [PK_utils_roomoramaLocations] PRIMARY KEY CLUSTERED ([id] ASC)
);

