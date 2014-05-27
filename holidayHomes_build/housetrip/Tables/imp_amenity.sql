CREATE TABLE [housetrip].[imp_amenity] (
    [sourceId]        INT            NOT NULL,
    [runId]           INT            NOT NULL,
    [fileId]          INT            NOT NULL,
    [amenityValue]    NVARCHAR (255) NULL,
    [amenityName]     NVARCHAR (255) NULL,
    [imp_amenitiesId] INT            NOT NULL
);




GO
CREATE CLUSTERED INDEX [CX_housetrip_imp_amenity_runId]
    ON [housetrip].[imp_amenity]([runId] ASC, [amenityValue] ASC, [imp_amenitiesId] ASC);

