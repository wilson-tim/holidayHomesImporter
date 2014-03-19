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

