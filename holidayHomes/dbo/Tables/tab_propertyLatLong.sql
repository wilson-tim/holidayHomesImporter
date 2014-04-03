CREATE TABLE [dbo].[tab_propertyLatLong] (
    [latlongID]  BIGINT            IDENTITY (1, 1) NOT NULL,
    [propertyId] BIGINT            NOT NULL,
    [latitude]   FLOAT (53)        NULL,
    [longitude]  FLOAT (53)        NULL,
    [geodata]    [sys].[geography] NULL,
    CONSTRAINT [PK_tab_propertyLatLong] PRIMARY KEY CLUSTERED ([latlongID] ASC, [propertyId] ASC)
);

GO

CREATE SPATIAL INDEX [SI_propertyLatLong]
    ON [dbo].[tab_propertyLatLong] ([geodata]);
GO

CREATE NONCLUSTERED INDEX [NCI_geodata] ON [dbo].[tab_propertyLatLong]
(
	[propertyId] ASC
)

INCLUDE ([geodata]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
GO

