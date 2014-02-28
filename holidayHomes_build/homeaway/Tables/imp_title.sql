CREATE TABLE [homeaway].[imp_title] (
    [sourceId] INT             NOT NULL,
    [runId]    INT             NOT NULL,
    [fileId]   INT             NOT NULL,
    [type]     NVARCHAR (255)  NULL,
    [text]     NVARCHAR (4000) NULL,
    [entry_id] INT             NULL
);

