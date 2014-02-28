CREATE TABLE [housetrip].[imp_amenity] (
    [sourceId]        INT            NOT NULL,
    [runId]           INT            NOT NULL,
    [fileId]          INT            NOT NULL,
    [amenityValue]    NVARCHAR (255) NULL,
    [amenityName]     NVARCHAR (255) NULL,
    [imp_amenitiesId] INT            NOT NULL
);

