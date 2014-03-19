CREATE TABLE [staging].[tab_property2amenity] (
    [sourceId]   INT    NOT NULL,
    [externalId] NVARCHAR (100)  NOT NULL,
    [amenityId]  BIGINT NOT NULL,
    [runId]      INT    NOT NULL,
    CONSTRAINT [PK_staging_tab_property2amenity] PRIMARY KEY CLUSTERED ([sourceId] ASC, [externalId] ASC, [amenityId] ASC),
    CONSTRAINT [FK_staging_tab_property2amenity_amenity] FOREIGN KEY ([amenityId]) REFERENCES [staging].[tab_amenity] ([amenityId]),
    CONSTRAINT [FK_staging_tab_property2amenity_property] FOREIGN KEY ([sourceId], [externalId]) REFERENCES [staging].[tab_property] ([sourceId], [externalId])
);

