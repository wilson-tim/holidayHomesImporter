CREATE TABLE [changeControl].[tab_amenity_change] (
    [runId]     INT           NOT NULL,
    [action]    NVARCHAR (10) NOT NULL,
    [amenityId] BIGINT        NOT NULL,
    CONSTRAINT [pk_amenity_change] PRIMARY KEY CLUSTERED ([runId] ASC, [action] ASC, [amenityId] ASC)
);

