CREATE TABLE [waytostay].[imp_room] (
    [sourceId] INT            NOT NULL,
    [runId]    INT            NOT NULL,
    [fileId]   INT            NOT NULL,
    [room_id]  INT            NOT NULL,
    [type]     NVARCHAR (255) NULL,
    [rooms_id] INT            NOT NULL
);

