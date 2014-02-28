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

