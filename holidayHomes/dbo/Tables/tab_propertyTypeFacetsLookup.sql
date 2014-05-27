CREATE TABLE [dbo].[tab_propertyTypeFacetsLookup] (
    [propertyType]        NVARCHAR (50) NOT NULL,
    [propertyTypeFacetId] INT           NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [PK_tab_propertyTypeFacetsLookup]
    ON [dbo].[tab_propertyTypeFacetsLookup]([propertyType] ASC, [propertyTypeFacetId] ASC);

