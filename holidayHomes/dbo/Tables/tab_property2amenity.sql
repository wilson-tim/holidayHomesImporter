CREATE TABLE [dbo].[tab_property2amenity] (
    [propertyId] BIGINT NOT NULL,
    [amenityId]  BIGINT NOT NULL,
    [runId]      INT    NOT NULL,
    CONSTRAINT [PK_tab_property2amenity] PRIMARY KEY CLUSTERED ([propertyId] ASC, [amenityId] ASC)
);

GO

CREATE NONCLUSTERED INDEX [IX_tab_property2amenity_amenityId]
ON [dbo].[tab_property2amenity] ([amenityId] ASC)

GO