CREATE TABLE [homeaway].[imp_rate] (
    [sourceId]     INT            NOT NULL,
    [runId]        INT            NOT NULL,
    [fileId]       INT            NOT NULL,
    [from]         FLOAT (53)     NULL,
    [to]           FLOAT (53)     NULL,
    [currencyUnit] NVARCHAR (3)   NULL,
    [periodType]   NVARCHAR (255) NULL,
    [rates_id]     INT            NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_homeaway_rate_runId_fileId]
    ON [homeaway].[imp_rate]([runId] ASC, [fileId] ASC)
    INCLUDE([from], [to], [currencyUnit], [periodType], [rates_id]);

