CREATE TABLE [dbo].[tab_propertyFeatured] (
    [sourceId]   INT            NOT NULL,
    [externalId] NVARCHAR (100) NOT NULL,
    CONSTRAINT [PK_tab_propertyFavourite] PRIMARY KEY CLUSTERED ([sourceId] ASC, [externalId] ASC)
);

