CREATE TABLE [roomorama].[imp_photo] (
    [images_Id] INT			     NULL,
    [room_Id]   INT			     NULL,
    [caption]   NVARCHAR (2000)   NULL,
    [position]  DECIMAL (28, 10) NULL,
    [imageUrl]  NVARCHAR (2000)  NULL,
    [runId]     INT              NULL,
    [fileId]    INT              NULL,
    [sourceId]  INT              NULL
);
GO

CREATE CLUSTERED INDEX [CX_roomorama_imp_photo_runId_fileId_room_Id_images_id]
    ON [roomorama].[imp_photo]([runId] ASC, [fileId] ASC, [room_Id] ASC, [images_Id] ASC);
GO

