CREATE TABLE [roomorama].[imp_image] (
    [images_Id] NUMERIC (20)     NULL,
    [room_Id]   NUMERIC (20)     NULL,
    [caption]   NVARCHAR (255)   NULL,
    [position]  DECIMAL (28, 10) NULL,
    [imageUrl]  NVARCHAR (2000)  NULL,
    [runId]     INT              NULL,
    [fileId]    INT              NULL,
    [sourceId]  INT              NULL
);

