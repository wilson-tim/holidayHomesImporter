CREATE TABLE [homeaway].[imp_content] (
    [sourceId]   INT            NOT NULL,
    [runId]      INT            NOT NULL,
    [fileId]     INT            NOT NULL,
    [content_id] INT            NULL,
    [type]       NVARCHAR (255) NULL,
    [entry_id]   INT            NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_homeaway_content_runId_fileId]
    ON [homeaway].[imp_content]([runId] ASC, [fileId] ASC)
    INCLUDE([content_id], [entry_id]);

