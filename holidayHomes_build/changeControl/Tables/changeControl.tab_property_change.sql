CREATE TABLE [changeControl].[tab_property_change] (
    [runId]      INT            NOT NULL,
    [action]     NVARCHAR (10)  NOT NULL,
    [sourceId]   INT            NOT NULL,
    [propertyId] BIGINT         NOT NULL,
    [externalId] NVARCHAR (100) NOT NULL,
    CONSTRAINT [pk_property_change] PRIMARY KEY CLUSTERED ([runId] ASC, [action] ASC, [sourceId] ASC, [propertyId] ASC)
);






GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_property_change_merge]
    ON [changeControl].[tab_property_change]([runId] ASC, [action] ASC, [sourceId] ASC, [externalId] ASC, [propertyId] ASC);

