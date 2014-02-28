CREATE TABLE [homeaway].[imp_link] (
    [sourceId] INT             NOT NULL,
    [runId]    INT             NOT NULL,
    [fileId]   INT             NOT NULL,
    [rel]      NVARCHAR (255)  NULL,
    [type]     NVARCHAR (255)  NULL,
    [hreflang] NVARCHAR (255)  NULL,
    [href]     NVARCHAR (2000) NULL,
    [entry_id] INT             NULL
);

