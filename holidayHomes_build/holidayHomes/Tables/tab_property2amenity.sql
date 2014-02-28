CREATE TABLE [holidayHomes].[tab_property2amenity] (
    [propertyId] BIGINT NOT NULL,
    [amenityId]  BIGINT NOT NULL,
    [runId]      INT    NOT NULL,
    CONSTRAINT [PK_tab_property2amenity] PRIMARY KEY CLUSTERED ([propertyId] ASC, [amenityId] ASC),
    CONSTRAINT [FK_tab_property2amenity_amenity] FOREIGN KEY ([amenityId]) REFERENCES [holidayHomes].[tab_amenity] ([amenityId]),
    CONSTRAINT [FK_tab_property2amenity_property] FOREIGN KEY ([propertyId]) REFERENCES [holidayHomes].[tab_property] ([propertyId])
);

