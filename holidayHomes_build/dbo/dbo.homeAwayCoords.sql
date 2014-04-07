CREATE TABLE [dbo].[homeAwayCoords] (
    [id]         INT        IDENTITY (1, 1) NOT NULL,
    [externalId] INT        NOT NULL,
    [latitude]   FLOAT (53) NULL,
    [longitude]  FLOAT (53) NULL,
    CONSTRAINT [PK_homeAwayCoords] PRIMARY KEY CLUSTERED ([id] ASC)
);
GO

CREATE NONCLUSTERED INDEX [NCI_latlongUpdate] ON [dbo].[homeAwayCoords]
(
	[externalId] ASC
)
INCLUDE ( 	[latitude],
	[longitude]) WITH (SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF) ON [PRIMARY];
GO

CREATE STATISTICS [_dta_stat_565577053_2_4] ON [dbo].[tab_property]([sourceId], [externalId]);
GO