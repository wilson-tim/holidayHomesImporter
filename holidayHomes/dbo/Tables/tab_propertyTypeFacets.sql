CREATE TABLE [dbo].[tab_propertyTypeFacets](
	[propertyTypeFacetId] [int] NOT NULL,
	[propertyTypeFacetName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tab_propertyTypeFacets] PRIMARY KEY NONCLUSTERED 
(
	[propertyTypeFacetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO