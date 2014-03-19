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

