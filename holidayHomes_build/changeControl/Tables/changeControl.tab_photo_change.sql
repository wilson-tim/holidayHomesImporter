CREATE TABLE [changeControl].[tab_photo_change] (
    [runId]      INT           NOT NULL,
    [action]     NVARCHAR (10) NOT NULL,
    [photoId]    BIGINT        NOT NULL,
    [propertyId] BIGINT        NOT NULL,
    CONSTRAINT [pk_photo_change] PRIMARY KEY CLUSTERED ([runId] ASC, [action] ASC, [photoId] ASC)
);

