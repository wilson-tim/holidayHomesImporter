CREATE TABLE [homeaway].[imp_author] (
    [sourceId] INT             NOT NULL,
    [runId]    INT             NOT NULL,
    [fileId]   INT             NOT NULL,
    [name]     NVARCHAR (255)  NULL,
    [uri]      NVARCHAR (2000) NULL
);

