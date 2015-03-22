CREATE TABLE [interhome].[imp_amenity] (
    [property_amenities_Id] BIGINT         NOT NULL,
    [property_Id]           BIGINT         NOT NULL,
    [runId]                 INT            NOT NULL,
    [fileId]                INT            NOT NULL,
    [sourceId]              INT            NOT NULL,
    [amenity]               NVARCHAR (255) NULL,
    [loopNo]                INT            NULL
);



