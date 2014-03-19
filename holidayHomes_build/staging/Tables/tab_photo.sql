CREATE TABLE [staging].[tab_photo] (
    [photoId]    BIGINT          IDENTITY (1, 1) NOT NULL,
    [sourceId]   INT             NOT NULL,
    [externalId] NVARCHAR (100)  NOT NULL,
    [position]   INT             NULL,
    [url]        NVARCHAR (2000) NULL,
    [runId]      INT             NOT NULL,
    CONSTRAINT [PK_photo] PRIMARY KEY CLUSTERED ([sourceId] ASC, [externalId] ASC, [photoId] ASC),
    CONSTRAINT [FK_tab_property_photo] FOREIGN KEY ([sourceId], [externalId]) REFERENCES [staging].[tab_property] ([sourceId], [externalId])
);

