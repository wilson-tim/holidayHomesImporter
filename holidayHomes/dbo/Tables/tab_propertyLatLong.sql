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

