CREATE TABLE [roomorama].[imp_amenity] (
    [sourceId]     INT              NOT NULL,
    [runId]        INT              NOT NULL,
    [fileId]       INT              NOT NULL,
    [id]           DECIMAL (28, 10) NULL,
    [amenityValue] NVARCHAR (255)   NULL
);

