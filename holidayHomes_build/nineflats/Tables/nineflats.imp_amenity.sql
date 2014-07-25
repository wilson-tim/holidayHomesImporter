CREATE TABLE [nineflats].[imp_amenity] (
    [property_amenities_Id] BIGINT         NOT NULL,
    [property_Id]           BIGINT         NOT NULL,
    [runId]                 INT            NOT NULL,
    [fileId]                INT            NOT NULL,
    [sourceId]              INT            NOT NULL,
    [amenity]               NVARCHAR (255) NULL
);




GO
CREATE CLUSTERED INDEX [CIX_imp_amenity]
    ON [nineflats].[imp_amenity]([runId] ASC, [fileId] ASC, [property_Id] ASC, [property_amenities_Id] ASC);

