CREATE TABLE [holidayHomes].[tab_photo] (
    [photoId]    BIGINT         IDENTITY (1, 1) NOT NULL,
    [propertyId] BIGINT         NOT NULL,
    [position]   INT            NULL,
    [url]        NVARCHAR (255) NULL,
    [runId]      INT            NOT NULL,
    CONSTRAINT [PK_photo] PRIMARY KEY CLUSTERED ([propertyId] ASC, [photoId] ASC),
    CONSTRAINT [FK_tab_property_photo] FOREIGN KEY ([propertyId]) REFERENCES [holidayHomes].[tab_property] ([propertyId])
);

