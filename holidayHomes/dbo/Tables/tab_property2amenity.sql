CREATE TABLE [dbo].[tab_property2amenity] (
    [propertyId] BIGINT NOT NULL,
    [amenityId]  BIGINT NOT NULL,
    [runId]      INT    NOT NULL,
    CONSTRAINT [PK_tab_property2amenity] PRIMARY KEY CLUSTERED ([propertyId] ASC, [amenityId] ASC)
);

