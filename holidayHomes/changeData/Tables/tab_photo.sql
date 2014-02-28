CREATE TABLE [changeData].[tab_photo] (
    [photoId]    BIGINT         NOT NULL,
    [propertyId] BIGINT         NOT NULL,
    [position]   INT            NULL,
    [url]        NVARCHAR (255) NULL,
    [runId]      INT            NOT NULL,
    CONSTRAINT [PK_photo] PRIMARY KEY CLUSTERED ([photoId] ASC)
);

