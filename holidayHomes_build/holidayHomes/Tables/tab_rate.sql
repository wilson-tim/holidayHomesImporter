CREATE TABLE [holidayHomes].[tab_rate] (
    [rateId]       BIGINT         IDENTITY (1, 1) NOT NULL,
    [propertyId]   BIGINT         NOT NULL,
    [periodType]   NVARCHAR (255) NULL,
    [from]         FLOAT (53)     NULL,
    [to]           FLOAT (53)     NULL,
    [currencyCode] NVARCHAR (3)   NULL,
    [runId]        INT            NOT NULL,
    CONSTRAINT [PK_rate] PRIMARY KEY CLUSTERED ([propertyId] ASC, [rateId] ASC),
    CONSTRAINT [FK_tab_property_rate] FOREIGN KEY ([propertyId]) REFERENCES [holidayHomes].[tab_property] ([propertyId])
);

