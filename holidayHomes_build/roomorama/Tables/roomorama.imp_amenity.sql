CREATE TABLE [roomorama].[imp_amenity] (
    [sourceId]     INT              NOT NULL,
    [runId]        INT              NOT NULL,
    [fileId]       INT              NOT NULL,
    [id]           INT NULL,
    [amenityValue] NVARCHAR (255)   NULL
);
GO

CREATE CLUSTERED INDEX [CX_roomorama_imp_amenity_runId_fileId_amenityValue]
    ON [roomorama].[imp_amenity]([runId] ASC, [fileId] ASC, [amenityValue] ASC, [id] ASC);
GO