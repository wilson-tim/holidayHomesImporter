CREATE TABLE [flipkey].[imp_amenity] (
    [property_amenities_Id] BIGINT          NOT NULL,
    [property_Id]           BIGINT          NOT NULL,
    [description]           NVARCHAR (4000) NULL,
    [parent_amenity]        NVARCHAR (255)  NULL,
    [site_amenity]          NVARCHAR (255)  NULL,
    [order]                 INT             NULL,
    [runId]                 INT             NOT NULL,
    [fileId]                INT             NOT NULL,
    [sourceId]              INT             NOT NULL, 
    [amenityValue] NVARCHAR(50) NULL 
);
GO

CREATE CLUSTERED INDEX [CX_flipkey_imp_amenity_runId_fileId_amenityValue]
    ON [flipkey].[imp_amenity]([runId] ASC, [fileId] ASC, [amenityValue] ASC, [property_amenities_Id] ASC, [property_Id] ASC);
GO