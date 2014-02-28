CREATE TABLE [waytostay].[imp_img] (
    [sourceId] INT             NOT NULL,
    [runId]    INT             NOT NULL,
    [fileId]   INT             NOT NULL,
    [default]  BIT             NULL,
    [text]     NVARCHAR (2000) NULL,
    [media_id] INT             NOT NULL
);

