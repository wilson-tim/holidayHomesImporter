CREATE TABLE [changeControl].[tab_rate_change] (
    [runId]      INT           NOT NULL,
    [action]     NVARCHAR (10) NOT NULL,
    [rateId]     BIGINT        NOT NULL,
    [propertyId] BIGINT        NOT NULL,
    CONSTRAINT [pk_rate_change] PRIMARY KEY CLUSTERED ([runId] ASC, [action] ASC, [rateId] ASC)
);

