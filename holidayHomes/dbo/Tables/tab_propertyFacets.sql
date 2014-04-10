CREATE TABLE [dbo].[tab_propertyFacets](
	[propertyFacetId] [int] NOT NULL,
	[propertyFacetName] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_tab_propertyFacets] PRIMARY KEY NONCLUSTERED 
(
	[propertyFacetId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO