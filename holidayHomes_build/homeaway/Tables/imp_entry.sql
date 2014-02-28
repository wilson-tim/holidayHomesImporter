CREATE TABLE [homeaway].[imp_entry] (
    [sourceId] INT             NOT NULL,
    [runId]    INT             NOT NULL,
    [fileId]   INT             NOT NULL,
    [entryId]  INT             NOT NULL,
    [id]       NVARCHAR (2000) NULL,
    [updated]  DATETIME        NULL,
    [summary]  NVARCHAR (4000) NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_homeaway_entry_runId_fileId]
    ON [homeaway].[imp_entry]([runId] ASC, [fileId] ASC)
    INCLUDE([sourceId], [entryId]);

