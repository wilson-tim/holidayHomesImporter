CREATE TABLE [homeaway].[imp_category] (
    [sourceId] INT             NOT NULL,
    [runId]    INT             NOT NULL,
    [fileId]   INT             NOT NULL,
    [term]     NVARCHAR (4000) NULL,
    [entry_id] INT             NOT NULL
);

