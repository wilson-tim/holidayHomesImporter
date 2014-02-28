CREATE TABLE [dbo].[tab_rate] (
    [rateId]       BIGINT         NOT NULL,
    [propertyId]   BIGINT         NOT NULL,
    [periodType]   NVARCHAR (255) NULL,
    [from]         FLOAT (53)     NULL,
    [to]           FLOAT (53)     NULL,
    [currencyCode] NVARCHAR (3)   NULL,
    [runId]        INT            NOT NULL,
    CONSTRAINT [PK_rate] PRIMARY KEY CLUSTERED ([propertyId] ASC, [rateId] ASC)
);

