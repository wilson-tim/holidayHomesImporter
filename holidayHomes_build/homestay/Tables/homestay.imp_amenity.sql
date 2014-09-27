CREATE TABLE [homestay].[imp_amenity] (
    [amenities_Id] BIGINT         NULL,
    [place_Id]     BIGINT         NULL,
    [amenity]      NVARCHAR (255) NULL,
    [runId]        INT            NULL,
    [fileId]       INT            NULL,
    [sourceId]     INT            NULL,
    [loopNo]       INT            NULL
);




GO
CREATE CLUSTERED INDEX [CIX_imp_amenity]
    ON [homestay].[imp_amenity]([runId] ASC, [fileId] ASC, [place_Id] ASC, [amenities_Id] ASC);

