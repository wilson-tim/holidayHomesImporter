CREATE TABLE [staging].[tab_rate] (
    [rateId]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [sourceId]     INT            NOT NULL,
    [externalId]   NVARCHAR (100) NOT NULL,
    [periodType]   NVARCHAR (255) NOT NULL,
    [from]         FLOAT (53)     NULL,
    [to]           FLOAT (53)     NULL,
    [currencyCode] NVARCHAR (3)   NULL,
    [runId]        INT            NOT NULL,
    CONSTRAINT [PK_rate] PRIMARY KEY CLUSTERED ([externalId] ASC, [periodType] ASC),
    CONSTRAINT [FK_tab_property_rate] FOREIGN KEY ([sourceId], [externalId]) REFERENCES [staging].[tab_property] ([sourceId], [externalId])
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tab_rate_merge]
    ON [staging].[tab_rate]([sourceId] ASC, [externalId] ASC, [from] ASC, [to] ASC, [periodType] ASC, [currencyCode] ASC)
    INCLUDE([runId]);

