CREATE TABLE [housetrip].[imp_photo] (
    [sourceId]     INT            NOT NULL,
    [runId]        INT            NOT NULL,
    [fileId]       INT            NOT NULL,
    [imp_photosId] INT            NOT NULL,
    [position]     INT            NULL,
    [url]          NVARCHAR (255) NULL
);

