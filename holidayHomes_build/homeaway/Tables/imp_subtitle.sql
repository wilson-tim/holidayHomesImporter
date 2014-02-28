CREATE TABLE [homeaway].[imp_subtitle] (
    [sourceId] INT             NOT NULL,
    [runId]    INT             NOT NULL,
    [fileId]   INT             NOT NULL,
    [type]     NVARCHAR (255)  NULL,
    [text]     NVARCHAR (4000) NULL
);

