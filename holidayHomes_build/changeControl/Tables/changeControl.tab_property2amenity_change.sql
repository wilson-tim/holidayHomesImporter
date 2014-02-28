CREATE TABLE [changeControl].[tab_property2amenity_change] (
    [runId]      INT           NOT NULL,
    [action]     NVARCHAR (10) NOT NULL,
    [propertyId] BIGINT        NOT NULL,
    [amenityId]  BIGINT        NOT NULL,
    CONSTRAINT [pk_property2amenity_change] PRIMARY KEY CLUSTERED ([runId] ASC, [action] ASC, [propertyId] ASC, [amenityId] ASC)
);

