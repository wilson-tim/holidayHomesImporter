CREATE TABLE [waytostay].[imp_amenity] (
    [sourceId]             INT            NOT NULL,
    [runId]                INT            NOT NULL,
    [fileId]               INT            NOT NULL,
    [name]                 NVARCHAR (255) NULL,
    [text]                 SMALLINT       NULL,
    [room_id]              INT            NULL,
    [facilities_id]        INT            NULL,
    [general_amenities_id] INT            NULL
);
GO

CREATE CLUSTERED INDEX [CX_waytostay_imp_amenity_runId_fileId_name]
    ON [waytostay].[imp_amenity]([runId] ASC, [fileId] ASC, [name] ASC, [room_id] ASC, [facilities_id] ASC, [general_amenities_id] ASC);
GO